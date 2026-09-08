package com.legacysimulator.v08;

// V8-ADD-011: SOAP、ESB、キューの送信実装を共通オーケストレータから分離する。
public interface PartnerClient {
    String partnerCode();
    String send(PartnerRequest request) throws PartnerCommunicationException;
}
