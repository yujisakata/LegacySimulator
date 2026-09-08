package com.legacysimulator.v07;

// V7-ADD-010: 社員向けSpring MVC Controller相当。
public final class EmployeeEntryController {
    private final ChannelApplicationService service;
    public EmployeeEntryController(ChannelApplicationService service) { this.service = service; }

    public ApplicationSummary show(String operatorId, String applicationNumber) {
        ChannelContext context = new ChannelContext("EMPLOYEE", operatorId, null);
        return service.find(context, applicationNumber);
    }
}
