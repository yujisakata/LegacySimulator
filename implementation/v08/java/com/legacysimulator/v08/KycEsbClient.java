package com.legacysimulator.v08;

// V8-FIX-002 ADD: 外部設計で定めたESB経由の本人確認クライアント。
public final class KycEsbClient implements PartnerClient {
    public String partnerCode() { return "KYC"; }
    public String send(PartnerRequest request) throws PartnerCommunicationException {
        if (request.getPayload() == null) throw new PartnerCommunicationException("本人確認要求が空です", false);
        return request.getTransactionId() + "|OK|KYC_VERIFIED";
    }
}
