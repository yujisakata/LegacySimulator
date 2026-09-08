package com.legacysimulator.v07;

// V7-ADD-001: 社員・代理店の参照登録範囲を入口で判定する。
public final class ChannelAccessPolicy {
    public boolean isAllowed(String channel, String agencyId, String ownerAgencyId) {
        if ("EMPLOYEE".equals(channel)) return true;
        return "AGENCY".equals(channel) && agencyId != null && agencyId.equals(ownerAgencyId);
    }
}
