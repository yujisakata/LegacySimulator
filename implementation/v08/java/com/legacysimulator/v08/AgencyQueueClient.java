package com.legacysimulator.v08;

// V8-ADD-015: 代理店基盤へ非同期キュー送信するクライアント。
public final class AgencyQueueClient implements PartnerClient {
    public String partnerCode() { return "AGENCY"; }
    public String send(PartnerRequest request) throws PartnerCommunicationException {
        return request.getTransactionId() + "|ACCEPTED|QUEUED";
    }
}
