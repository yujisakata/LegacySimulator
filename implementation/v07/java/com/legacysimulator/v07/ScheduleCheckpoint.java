package com.legacysimulator.v07;

import java.util.Date;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Set;

// V7-ADD-012: JavaとCOBOLの別スケジューラ間で照合するチェックポイント。
public final class ScheduleCheckpoint {
    private final String businessDate;
    private Date javaExportCompletedAt;
    private Date cobolImportCompletedAt;
    // V7-FIX-001 DEL: 件数だけでは同数の別申込への入替を検知できないため、旧項目を履歴として残す。
    // private int exportedCount;
    // private int importedCount;
    // V7-FIX-001 ADD: 要件どおり、実行日内の受付番号集合を照合する。
    private Set<String> exportedApplicationNumbers = Collections.emptySet();
    private Set<String> importedApplicationNumbers = Collections.emptySet();

    public ScheduleCheckpoint(String businessDate) { this.businessDate = businessDate; }
    // V7-FIX-001 DEL: public void recordJavaExport(Date at, int count) { javaExportCompletedAt = at; exportedCount = count; }
    // V7-FIX-001 DEL: public void recordCobolImport(Date at, int count) { cobolImportCompletedAt = at; importedCount = count; }
    // V7-FIX-001 ADD: 重複を除いた受付番号を保存し、後続処理で差分を説明可能にする。
    public void recordJavaExport(Date at, Collection<String> applicationNumbers) {
        javaExportCompletedAt = at;
        exportedApplicationNumbers = copyOf(applicationNumbers);
    }
    public void recordCobolImport(Date at, Collection<String> applicationNumbers) {
        cobolImportCompletedAt = at;
        importedApplicationNumbers = copyOf(applicationNumbers);
    }
    public String getBusinessDate() { return businessDate; }
    public boolean isComplete() { return javaExportCompletedAt != null && cobolImportCompletedAt != null; }
    // V7-FIX-001 DEL: public boolean hasCountDifference() { return isComplete() && exportedCount != importedCount; }
    // V7-FIX-001 ADD: 件数一致でも受付番号が異なれば受渡し不一致とする。
    public boolean hasApplicationDifference() {
        return isComplete() && !exportedApplicationNumbers.equals(importedApplicationNumbers);
    }
    public Set<String> missingApplicationNumbers() {
        Set<String> result = new LinkedHashSet<>(exportedApplicationNumbers);
        result.removeAll(importedApplicationNumbers);
        return Collections.unmodifiableSet(result);
    }
    public Set<String> unexpectedApplicationNumbers() {
        Set<String> result = new LinkedHashSet<>(importedApplicationNumbers);
        result.removeAll(exportedApplicationNumbers);
        return Collections.unmodifiableSet(result);
    }
    private Set<String> copyOf(Collection<String> values) {
        if (values == null) { throw new IllegalArgumentException("受付番号一覧は必須です"); }
        return Collections.unmodifiableSet(new LinkedHashSet<>(values));
    }
}
