package com.legacysimulator.v07;

// V7-ADD-005: Controllerから共通Serviceへ渡す操作者・チャネル情報。
public final class ChannelContext {
    private final String channel;
    private final String operatorId;
    private final String agencyId;

    public ChannelContext(String channel, String operatorId, String agencyId) {
        this.channel = channel;
        this.operatorId = operatorId;
        this.agencyId = agencyId;
    }
    public String getChannel() { return channel; }
    public String getOperatorId() { return operatorId; }
    public String getAgencyId() { return agencyId; }
}
