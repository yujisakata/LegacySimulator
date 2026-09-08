package com.legacysimulator.v06;

// V6-ADD-003: 正式インターフェースである80文字固定長を生成する。
public final class CobolEntryFileGateway {
    public String format(EntryRequest request) {
        String amount = String.format("%010d", request.insuredAmount().longValueExact());
        return String.format("%-10s%-2s%03d%s%-55s",
                request.applicationNumber(), request.productCode(), request.age(), amount, "");
    }
}
