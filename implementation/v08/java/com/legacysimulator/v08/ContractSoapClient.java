package com.legacysimulator.v08;

// V8-FIX-002 ADD: 外部設計で定めたSOAP経由の契約内容照会クライアント。
public final class ContractSoapClient implements PartnerClient {
    public String partnerCode() { return "CONTRACT"; }
    public String send(PartnerRequest request) throws PartnerCommunicationException {
        if (request.getApplicationNumber() == null) throw new PartnerCommunicationException("受付番号が空です", false);
        return request.getTransactionId() + "|OK|CONTRACT_FOUND";
    }
}
