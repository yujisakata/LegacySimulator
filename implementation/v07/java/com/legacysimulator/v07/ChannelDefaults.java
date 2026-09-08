package com.legacysimulator.v07;

// V7-ADD-002: COBOLが再解釈するチャネル既定値を明示する。
public final class ChannelDefaults {
    public String cobolOfficeCode(String channel) {
        return "AGENCY".equals(channel) ? "AG" : "OF";
    }
}
