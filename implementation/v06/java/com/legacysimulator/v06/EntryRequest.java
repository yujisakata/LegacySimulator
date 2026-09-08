package com.legacysimulator.v06;

import java.math.BigDecimal;

// V6-ADD-001: Web受付で保持する入力項目。
public record EntryRequest(String applicationNumber, String productCode, int age, BigDecimal insuredAmount) {
}
