package com.legacysimulator.v07;

import java.util.Date;
import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

// V7-ADD-013: 二つのスケジューラの完了連絡を業務日単位で相関する。
public final class ScheduleCoordinationService {
    private final Map<String, ScheduleCheckpoint> checkpoints = new ConcurrentHashMap<>();

    // V7-FIX-001 DEL: public void javaExportCompleted(String businessDate, int count, Date at)
    // V7-FIX-001 ADD: 実行日と受付番号を組み合わせて受渡しを相関する。
    public void javaExportCompleted(String businessDate, Collection<String> applicationNumbers, Date at) {
        checkpoint(businessDate).recordJavaExport(at, applicationNumbers);
    }
    // V7-FIX-001 DEL: public void cobolImportCompleted(String businessDate, int count, Date at)
    // V7-FIX-001 ADD: COBOL取込済み受付番号を保存し、欠落・想定外を識別する。
    public void cobolImportCompleted(String businessDate, Collection<String> applicationNumbers, Date at) {
        checkpoint(businessDate).recordCobolImport(at, applicationNumbers);
    }
    public ScheduleCheckpoint status(String businessDate) { return checkpoints.get(businessDate); }
    private ScheduleCheckpoint checkpoint(String date) {
        return checkpoints.computeIfAbsent(date, ScheduleCheckpoint::new);
    }
}
