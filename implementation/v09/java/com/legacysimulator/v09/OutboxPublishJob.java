package com.legacysimulator.v09;

// V9-FIX-002 ADD: 起動後・定期実行時に未発行Outboxを再送する。
public final class OutboxPublishJob {
    private final KycOutboxRepository repository;
    private final KycAdapterService.MessagePublisher publisher;
    public OutboxPublishJob(KycOutboxRepository repository, KycAdapterService.MessagePublisher publisher) {
        this.repository = repository;
        this.publisher = publisher;
    }
    public int execute(int limit) {
        int published = 0;
        for (OutboxMessage message : repository.findUnpublished(limit)) {
            try {
                publisher.publish(message.transactionKey(), message.result());
                repository.markPublished(message.transactionKey());
                published++;
            } catch (RuntimeException retryOnNextRun) {
                // V9-FIX-002 ADD: 未発行状態を維持し、次回実行の再送対象に残す。
            }
        }
        return published;
    }
}
