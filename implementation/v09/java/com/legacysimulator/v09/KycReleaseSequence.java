package com.legacysimulator.v09;

// V9-ADD-004: 共有DB保存後にだけメッセージ発行を許可する順序契約。
public final class KycReleaseSequence {
    public interface Store { boolean save(String transactionKey, String result); }
    public interface Publisher { void publish(String transactionKey); }
    public boolean complete(String key, String result, Store store, Publisher publisher) {
        if (!store.save(key, result)) return false;
        publisher.publish(key);
        return true;
    }
}
