package com.legacysimulator.v08;

import java.util.Comparator;
import java.util.List;

// V8-ADD-017: 運用承認済み対象を再送する。
public final class RetryDispatchJob {
    private final IntegrationStateRepository repository;
    private final IntegrationOrchestrator orchestrator;
    public RetryDispatchJob(IntegrationStateRepository repository, IntegrationOrchestrator orchestrator) {
        this.repository = repository;
        this.orchestrator = orchestrator;
    }
    public int execute(int maximumRetryCount) {
        List<IntegrationState> targets = repository.findRetryTargets(maximumRetryCount, 1000);
        // V8-FIX-001 DEL: targets.sort(Comparator.comparing(IntegrationState::getUpdatedAt)
        // V8-FIX-001 DEL:         .thenComparing(state -> state.getRequest().getTransactionId()));
        // V8-FIX-001 ADD: 更新時刻ではなく、初回受付時のキュー番号順を維持する。
        targets.sort(Comparator.comparingLong(IntegrationState::getSequence));
        int success = 0;
        for (IntegrationState target : targets) {
            try {
                // V8-FIX-001 DEL: if (orchestrator.execute(target.getRequest(), sequence++) != null) success++;
                // V8-FIX-001 ADD: 既存状態を再利用し、同一状態行の重複作成を防止する。
                if (orchestrator.retry(target) != null) success++;
            } catch (PartnerCommunicationException error) {
                // V8-ADD-018: 次回の運用再送へ残し、後続取引を継続する。
            }
        }
        return success;
    }
}
