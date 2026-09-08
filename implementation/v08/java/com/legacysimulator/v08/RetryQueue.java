package com.legacysimulator.v08;

import java.util.Comparator;
import java.util.PriorityQueue;

// V8-ADD-005: 運用で承認された受付順を維持する再送キュー。
public final class RetryQueue {
    private final PriorityQueue<CanonicalResponse> queue = new PriorityQueue<>(Comparator.comparingLong(CanonicalResponse::sequence));
    public void enqueue(CanonicalResponse response) { queue.add(response); }
    public CanonicalResponse poll() { return queue.poll(); }
}
