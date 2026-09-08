package com.legacysimulator.v07;

import java.util.List;

// V7-ADD-008: チャネル別Controllerから利用する共通業務サービス。
public final class ChannelApplicationService {
    private final ApplicationQueryPort queryPort;
    private final ChannelAccessPolicy accessPolicy;
    private final ChannelDefaults defaults;

    public ChannelApplicationService(ApplicationQueryPort queryPort,
                                     ChannelAccessPolicy accessPolicy,
                                     ChannelDefaults defaults) {
        this.queryPort = queryPort;
        this.accessPolicy = accessPolicy;
        this.defaults = defaults;
    }

    public ApplicationSummary find(ChannelContext context, String applicationNumber) {
        ApplicationSummary application = queryPort.find(applicationNumber);
        if (application == null) return null;
        if (!accessPolicy.isAllowed(context.getChannel(), context.getAgencyId(),
                application.getOwnerAgencyId())) {
            throw new ChannelAuthorizationException("対象申込を扱う権限がありません");
        }
        return application;
    }

    public List<ApplicationSummary> listAgencyApplications(ChannelContext context, int limit) {
        if (!"AGENCY".equals(context.getChannel()) || context.getAgencyId() == null) {
            throw new ChannelAuthorizationException("代理店チャネルではありません");
        }
        return queryPort.findByAgency(context.getAgencyId(), limit);
    }

    public String resolveCobolOfficeCode(ChannelContext context) {
        return defaults.cobolOfficeCode(context.getChannel());
    }
}
