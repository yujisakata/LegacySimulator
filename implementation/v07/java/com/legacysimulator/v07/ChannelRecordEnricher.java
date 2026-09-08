package com.legacysimulator.v07;

// V7-ADD-003: V6予約領域だけを利用し、既存項目位置を維持する。
public final class ChannelRecordEnricher {
    public String enrich(String v6Record, String officeCode, String agencyId) {
        if (v6Record == null || v6Record.length() != 80) throw new IllegalArgumentException("V6レコードは80文字です");
        String normalizedAgency = agencyId == null ? "" : agencyId;
        return v6Record.substring(0, 25)
                + String.format("%-2s%-10s", officeCode, normalizedAgency)
                + v6Record.substring(37);
    }
}
