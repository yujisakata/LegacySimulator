package com.legacysimulator.v06;

import java.math.BigDecimal;

// V6-ADD-004: 月末処理対策として高額案件を後続ジョブへ分離する。
public final class BatchLaneSelector {
    private static final BigDecimal HIGH_VALUE = new BigDecimal("20000000");

    public String select(EntryRequest request) {
        return request.insuredAmount().compareTo(HIGH_VALUE) >= 0 ? "HIGH" : "NORMAL";
    }
}
