package com.legacysimulator.v09;

import java.util.List;

// V9-ADD-015: 共有DB更新とメッセージ発行要求を同じトランザクションで記録する。
public interface KycOutboxRepository {
    boolean saveResultAndOutbox(String transactionKey, String result, String auditReason);
    void markPublished(String transactionKey);
    // V9-FIX-002 ADD: 障害復旧後に未発行要求を再取得する。
    List<OutboxMessage> findUnpublished(int limit);
}
