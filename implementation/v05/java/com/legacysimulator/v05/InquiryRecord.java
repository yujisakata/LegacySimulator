package com.legacysimulator.v05;

import java.math.BigDecimal;
import java.sql.Date;

/** V5-ADD-001: 照会用複製。査定ロジックは持たない。 */
public final class InquiryRecord {
    public final String number, product, status, rule, reason, approval;
    public final BigDecimal amount;
    public final Date responsibility, processed, received, applied, asOf;
    public InquiryRecord(String number, String product, String status,
            BigDecimal amount, Date responsibility, Date processed,
            Date received, String rule, Date applied, Date asOf,
            String reason, String approval) {
        this.number=number; this.product=product; this.status=status;
        this.amount=amount; this.responsibility=responsibility;
        this.processed=processed; this.received=received; this.rule=rule;
        this.applied=applied; this.asOf=asOf; this.reason=reason;
        this.approval=approval;
    }
}
