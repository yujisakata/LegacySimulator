package com.legacysimulator.v08;

import java.util.Date;

// V8-ADD-007: 外部応答待ちの間も受付状態を保持する連携状態。
public final class IntegrationState {
    public static final String PENDING_EXTERNAL = "PENDING_EXTERNAL";
    public static final String COMPLETED = "COMPLETED";
    public static final String RETRY_WAIT = "RETRY_WAIT";
    private final PartnerRequest request;
    // V8-FIX-001 ADD: 初回受付時のキュー番号を再送後まで保持する。
    private final long sequence;
    private String status = PENDING_EXTERNAL;
    private int retryCount;
    private Date updatedAt = new Date();
    // V8-FIX-001 DEL: public IntegrationState(PartnerRequest request) { this.request = request; }
    // V8-FIX-001 ADD: 再送順の根拠となる初回キュー番号を必須化する。
    public IntegrationState(PartnerRequest request, long sequence) {
        if (sequence < 1) { throw new IllegalArgumentException("キュー番号は1以上です"); }
        this.request = request;
        this.sequence = sequence;
    }
    public PartnerRequest getRequest() { return request; }
    public long getSequence() { return sequence; }
    public String getStatus() { return status; }
    public int getRetryCount() { return retryCount; }
    public Date getUpdatedAt() { return new Date(updatedAt.getTime()); }
    public void complete() { status = COMPLETED; updatedAt = new Date(); }
    public void waitForRetry() { status = RETRY_WAIT; retryCount++; updatedAt = new Date(); }

    // V8-ADD-021: 再送ジョブがDBの状態・回数・更新時刻を復元する。
    void restore(String persistedStatus, int persistedRetryCount, Date persistedUpdatedAt) {
        status = persistedStatus;
        retryCount = persistedRetryCount;
        updatedAt = new Date(persistedUpdatedAt.getTime());
    }
}
