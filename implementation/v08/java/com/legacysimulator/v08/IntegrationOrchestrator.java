package com.legacysimulator.v08;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

// V8-ADD-016: 受付状態保存、接続先選択、応答変換、再送待ちを統括する。
public final class IntegrationOrchestrator {
    private final Map<String, PartnerClient> clients = new HashMap<>();
    private final IntegrationStateRepository repository;
    private final DuplicateResponseGuard duplicateGuard;
    private final DelimitedPartnerAdapter responseAdapter;

    public IntegrationOrchestrator(List<PartnerClient> clients,
                                   IntegrationStateRepository repository,
                                   DuplicateResponseGuard duplicateGuard) {
        for (PartnerClient client : clients) this.clients.put(client.partnerCode(), client);
        this.repository = repository;
        this.duplicateGuard = duplicateGuard;
        this.responseAdapter = new DelimitedPartnerAdapter("COMMON");
    }

    public CanonicalResponse execute(PartnerRequest request, long sequence)
            throws PartnerCommunicationException {
        // V8-FIX-001 DEL: IntegrationState state = new IntegrationState(request);
        // V8-FIX-001 ADD: 初回だけ状態行を作成し、受付キュー番号を永続化する。
        IntegrationState state = new IntegrationState(request, sequence);
        repository.create(state);
        return send(state);
    }

    // V8-FIX-001 ADD: 再送では既存状態を更新し、同一主キーの再作成を行わない。
    public CanonicalResponse retry(IntegrationState state)
            throws PartnerCommunicationException {
        if (!IntegrationState.RETRY_WAIT.equals(state.getStatus())) {
            throw new IllegalArgumentException("再送待ち以外の状態は再送できません");
        }
        return send(state);
    }

    private CanonicalResponse send(IntegrationState state)
            throws PartnerCommunicationException {
        PartnerRequest request = state.getRequest();
        long sequence = state.getSequence();
        PartnerClient client = clients.get(request.getPartner());
        if (client == null) throw new IllegalArgumentException("未登録の接続先です: " + request.getPartner());
        try {
            String raw = client.send(request);
            CanonicalResponse response = new DelimitedPartnerAdapter(client.partnerCode()).adapt(raw, sequence);
            if (duplicateGuard.accept(response)) {
                state.complete();
                repository.save(state);
                return response;
            }
            return null;
        } catch (PartnerCommunicationException error) {
            if (error.isRetryable()) { state.waitForRetry(); repository.save(state); }
            throw error;
        }
    }
}
