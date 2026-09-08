package com.legacysimulator.v07;

import java.util.List;

// V7-ADD-011: 代理店認証で得た代理店番号を必ずServiceへ渡す入口。
public final class AgencyEntryController {
    private final ChannelApplicationService service;
    public AgencyEntryController(ChannelApplicationService service) { this.service = service; }

    public ApplicationSummary show(String operatorId, String agencyId, String applicationNumber) {
        return service.find(new ChannelContext("AGENCY", operatorId, agencyId), applicationNumber);
    }

    public List<ApplicationSummary> list(String operatorId, String agencyId) {
        return service.listAgencyApplications(new ChannelContext("AGENCY", operatorId, agencyId), 100);
    }
}
