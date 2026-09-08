package com.legacysimulator.v09;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.List;

// V9-ADD-013: 発生元ログを夜間に監査DBへ集約し、件数を返す。
public final class AuditAggregationJob {
    private final AuditRepository repository;
    public AuditAggregationJob(AuditRepository repository) { this.repository = repository; }

    public AggregationResult importFile(String path, SourceAuditMapper mapper) throws Exception {
        BufferedReader reader = new BufferedReader(new FileReader(path));
        int input = 0;
        int inserted = 0;
        int duplicate = 0;
        int error = 0;
        try {
            String line;
            while ((line = reader.readLine()) != null) {
                input++;
                try {
                    if (repository.appendIfAbsent(mapper.map(line))) inserted++; else duplicate++;
                } catch (RuntimeException mappingOrDatabaseError) {
                    error++;
                }
            }
        } finally { reader.close(); }
        return new AggregationResult(input, inserted, duplicate, error);
    }
}
