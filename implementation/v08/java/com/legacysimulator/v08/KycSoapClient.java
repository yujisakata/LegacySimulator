package com.legacysimulator.v08;

// V8-ADD-013: 本人確認先のSOAPクライアント。通信ライブラリ呼出し位置を限定する。
public final class KycSoapClient implements PartnerClient {
    public String partnerCode() { return "KYC"; }
    public String send(PartnerRequest request) throws PartnerCommunicationException {
        if (request.getPayload() == null) throw new PartnerCommunicationException("本人確認要求が空です", false);
        return request.getTransactionId() + "|OK|KYC_VERIFIED";
    }
}
