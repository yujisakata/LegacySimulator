package com.legacysimulator.v08;

// V8-ADD-003: デモ用の接続先別区切り応答アダプタ。
public final class DelimitedPartnerAdapter implements PartnerAdapter {
    private final String partner;
    public DelimitedPartnerAdapter(String partner) { this.partner = partner; }
    public CanonicalResponse adapt(String rawResponse, long sequence) {
        String[] fields = rawResponse.split("\\|", 3);
        if (fields.length != 3) throw new IllegalArgumentException("外部応答は取引ID|状態|内容です");
        return new CanonicalResponse(partner, fields[0], fields[1], fields[2], sequence);
    }
}
