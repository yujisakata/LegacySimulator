package com.legacysimulator.v07;

// V7-ADD-009: 権限エラーを共通Serviceからチャネル別入口へ通知する。
public final class ChannelAuthorizationException extends RuntimeException {
    public ChannelAuthorizationException(String message) { super(message); }
}
