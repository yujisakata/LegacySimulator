package com.legacysimulator.v09;

// V9-ADD-017: KYC接続先の個別周期で配布するREST入口相当。
public final class KycResultController {
    private final KycAdapterService service;
    public KycResultController(KycAdapterService service) { this.service = service; }
    public int postResult(String transactionKey, String result, String reason) {
        if (transactionKey == null || transactionKey.trim().isEmpty()) return 400;
        return service.complete(transactionKey, result, reason) ? 202 : 409;
    }
}
