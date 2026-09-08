package com.legacysimulator.v06;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.List;

// V6-ADD-014: 受付締め後に通常・高額の二つの固定長ファイルを生成する。
public final class CobolExportBatch {
    private final EntryRepository repository;
    private final CobolEntryFileGateway gateway;
    private final BatchLaneSelector laneSelector;

    public CobolExportBatch(EntryRepository repository, CobolEntryFileGateway gateway,
                            BatchLaneSelector laneSelector) {
        this.repository = repository;
        this.gateway = gateway;
        this.laneSelector = laneSelector;
    }

    public ExportCounts execute(String normalPath, String highPath) throws Exception {
        BufferedWriter normal = new BufferedWriter(new FileWriter(normalPath));
        BufferedWriter high = new BufferedWriter(new FileWriter(highPath));
        int normalCount = 0;
        int highCount = 0;
        try {
            List<EntryApplication> targets = repository.findReadyForCobol(100000);
            for (EntryApplication target : targets) {
                EntryRequest request = new EntryRequest(target.getApplicationNumber(), target.getProductCode(),
                        target.getAge(), target.getInsuredAmount());
                BufferedWriter writer = "HIGH".equals(laneSelector.select(request)) ? high : normal;
                writer.write(gateway.format(request));
                writer.newLine();
                repository.updateStatus(target.getApplicationNumber(), EntryApplication.READY_FOR_COBOL,
                        EntryApplication.SENT_TO_COBOL);
                if (writer == high) highCount++; else normalCount++;
            }
            return new ExportCounts(normalCount, highCount);
        } finally { normal.close(); high.close(); }
    }
}
