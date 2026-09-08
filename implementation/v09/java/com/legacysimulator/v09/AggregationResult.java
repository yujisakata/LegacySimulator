package com.legacysimulator.v09;

// V9-ADD-014: 発生元件数、登録、重複、変換エラーの監査運用照合値。
public final class AggregationResult {
    public final int inputCount;
    public final int insertedCount;
    public final int duplicateCount;
    public final int errorCount;
    public AggregationResult(int input, int inserted, int duplicate, int error) {
        inputCount=input; insertedCount=inserted; duplicateCount=duplicate; errorCount=error;
    }
}
