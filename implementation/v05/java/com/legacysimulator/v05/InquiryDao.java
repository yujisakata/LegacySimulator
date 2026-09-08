package com.legacysimulator.v05;

// V5-ADD-007: Web照会が利用する読取専用データアクセス境界。
public interface InquiryDao {
    InquiryRecord find(String contractNumber);
}
