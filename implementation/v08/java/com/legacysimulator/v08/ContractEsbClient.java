package com.legacysimulator.v08;

// V8-ADD-014: 契約内容照会を社内ESBへ送るクライアント。
public final class ContractEsbClient implements PartnerClient {
    public String partnerCode() { return "CONTRACT"; }
    public String send(PartnerRequest request) throws PartnerCommunicationException {
        if (request.getApplicationNumber() == null) throw new PartnerCommunicationException("受付番号が空です", false);
        return request.getTransactionId() + "|OK|CONTRACT_FOUND";
    }
}
