package com.legacysimulator.v05;

import java.math.BigDecimal;

// V5-ADD-002: COBOL固定長スナップショットを照会モデルへ一方向変換する。
public final class FixedLengthInquiryConverter {
    private static final int RECORD_LENGTH = 40;

    public InquiryRecord convert(String line) {
        if (line == null || line.length() != RECORD_LENGTH) {
            throw new IllegalArgumentException("固定長レコードは40文字である必要があります");
        }
        String contractNumber = line.substring(0, 10).trim();
        String status = nullableText(line.substring(10, 12));
        BigDecimal insuredAmount = nullableNumber(line.substring(12, 22));
        String asOfDate = requireDate(line.substring(22, 30));
        return new InquiryRecord(contractNumber, status, insuredAmount, asOfDate);
    }

    private String nullableText(String value) {
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private BigDecimal nullableNumber(String value) {
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : new BigDecimal(trimmed);
    }

    // V5-ADD-006: Java照会では文字列の基準日を保持し、DB変換時に検査する。
    private String requireDate(String value) {
        if (value == null || value.length() != 8 || !isDigits(value)) {
            throw new IllegalArgumentException("基準日は8桁数字です");
        }
        return value;
    }

    private boolean isDigits(String value) {
        for (int index = 0; index < value.length(); index++) {
            if (!Character.isDigit(value.charAt(index))) return false;
        }
        return true;
    }
}
