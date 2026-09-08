package com.legacysimulator.v08;

// V8-ADD-010: 接続先障害と自社DB障害を区別するための永続化例外。
public final class IntegrationPersistenceException extends RuntimeException {
    public IntegrationPersistenceException(String message, Throwable cause) { super(message, cause); }
}
