package com.legacysimulator.v05;

// V5-ADD-010: JDBC例外をWeb層へ直接公開しないための実行時例外。
public final class InquiryDataAccessException extends RuntimeException {
    public InquiryDataAccessException(String message, Throwable cause) {
        super(message, cause);
    }
}
