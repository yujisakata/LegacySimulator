package com.legacysimulator.v05;

import java.util.Optional;

// V5-ADD-003: 更新操作を持たない契約照会サービス。
public final class InquirySnapshotService {
    private final InquiryDao inquiryDao;

    public InquirySnapshotService(InquiryDao inquiryDao) {
        this.inquiryDao = inquiryDao;
    }

    public Optional<InquiryRecord> findByContractNumber(String contractNumber) {
        if (contractNumber == null || contractNumber.length() != 10) {
            return Optional.empty();
        }
        return Optional.ofNullable(inquiryDao.find(contractNumber));
    }
}
