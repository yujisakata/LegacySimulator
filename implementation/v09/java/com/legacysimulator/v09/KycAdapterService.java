package com.legacysimulator.v09;

// V9-ADD-016: Spring Bootとして独立配布する本人確認結果サービス。
public final class KycAdapterService {
    public interface MessagePublisher { void publish(String transactionKey, String result); }
    private final KycOutboxRepository repository;
    private final MessagePublisher publisher;
    public KycAdapterService(KycOutboxRepository repository, MessagePublisher publisher) {
        this.repository = repository;
        this.publisher = publisher;
    }
    public boolean complete(String key, String result, String reason) {
        if (!repository.saveResultAndOutbox(key, result, reason)) return false;
        publisher.publish(key, result);
        repository.markPublished(key);
        return true;
    }
}
