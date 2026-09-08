package com.legacysimulator.v06;

import java.util.Date;
import java.util.List;

// V6-ADD-011: 即時点検、受付保存、COBOL連携準備までを一つの受付トランザクションで行う。
public final class EntryWorkflowService {
    private final EntryValidationService validationService;
    private final EntryRepository repository;
    private final BatchLaneSelector laneSelector;

    public EntryWorkflowService(EntryValidationService validationService,
                                EntryRepository repository,
                                BatchLaneSelector laneSelector) {
        this.validationService = validationService;
        this.repository = repository;
        this.laneSelector = laneSelector;
    }

    public EntryReceipt accept(EntryRequest request, Date receivedAt) {
        List<String> messages = validationService.validate(request);
        if (!messages.isEmpty()) return EntryReceipt.rejected(messages);
        EntryApplication application = new EntryApplication(request, receivedAt);
        application.markReadyForCobol();
        repository.save(application);
        return EntryReceipt.accepted(request.applicationNumber(), laneSelector.select(request));
    }
}
