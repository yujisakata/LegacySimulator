package com.legacysimulator.v10;

import java.time.Instant;

// V10-ADD-014: AI候補に対する人手の承認・保留・反証を別記録として残す。
public record ReviewDecision(String edgeId, String reviewerRole, Outcome outcome,
                             String rationale, Instant reviewedAt) {
    public enum Outcome { APPROVE, KEEP_PENDING, CONTRADICT }
}
