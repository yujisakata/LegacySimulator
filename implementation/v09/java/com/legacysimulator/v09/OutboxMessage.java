package com.legacysimulator.v09;

// V9-FIX-002 ADD: 未発行本人確認結果を再送ジョブへ渡す値オブジェクト。
public final class OutboxMessage {
    private final String transactionKey;
    private final String result;
    public OutboxMessage(String transactionKey, String result) {
        this.transactionKey = transactionKey;
        this.result = result;
    }
    public String transactionKey() { return transactionKey; }
    public String result() { return result; }
}
