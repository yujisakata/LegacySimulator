package com.legacysimulator.v08;

// V8-ADD-002: SOAP/ESB/QUEUEの差分を接続先実装へ限定する。
public interface PartnerAdapter {
    CanonicalResponse adapt(String rawResponse, long sequence);
}
