package com.legacysimulator.v06;

// V6-ADD-010: DB例外を受付サービスの境界へ変換する。
public final class EntryRepositoryException extends RuntimeException {
    public EntryRepositoryException(String message, Throwable cause) { super(message, cause); }
}
