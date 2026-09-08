package com.legacysimulator.v08;

// V8-ADD-012: 自動再送の対象となる外部通信例外。
public final class PartnerCommunicationException extends Exception {
    private final boolean retryable;
    public PartnerCommunicationException(String message, boolean retryable) { super(message); this.retryable = retryable; }
    public boolean isRetryable() { return retryable; }
}
