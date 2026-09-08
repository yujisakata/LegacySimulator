package com.legacysimulator.v09;

// V9-ADD-012: 監査集約ジョブが検知する永続化例外。
public final class AuditPersistenceException extends RuntimeException {
    public AuditPersistenceException(String message, Throwable cause) { super(message, cause); }
}
