package com.legacysimulator.v07;

// V7-ADD-006: 社員・代理店画面で共通利用する受付概要。
public final class ApplicationSummary {
    private final String applicationNumber;
    private final String ownerAgencyId;
    private final String productCode;
    private final String status;

    public ApplicationSummary(String applicationNumber, String ownerAgencyId,
                              String productCode, String status) {
        this.applicationNumber = applicationNumber;
        this.ownerAgencyId = ownerAgencyId;
        this.productCode = productCode;
        this.status = status;
    }
    public String getApplicationNumber() { return applicationNumber; }
    public String getOwnerAgencyId() { return ownerAgencyId; }
    public String getProductCode() { return productCode; }
    public String getStatus() { return status; }
}
