package com.legacysimulator.v10;

import java.util.Map;

// V10-ADD-012: PowerShell参照実装と同じ確信度規則をJava 21側にも明示する。
public final class EvidencePolicy {
    public Assessment assess(Map<String, Boolean> evidence, boolean contradicted) {
        double score = 0.0;
        if (Boolean.TRUE.equals(evidence.get("requirement"))) score += 0.2;
        if (Boolean.TRUE.equals(evidence.get("design"))) score += 0.2;
        if (Boolean.TRUE.equals(evidence.get("code"))) score += 0.3;
        if (Boolean.TRUE.equals(evidence.get("test"))) score += 0.3;
        if (contradicted) score = Math.min(score, 0.5);
        score = Math.round(score * 100.0) / 100.0;
        EvidenceEdge.ReviewStatus status = contradicted || score < 0.8
                ? EvidenceEdge.ReviewStatus.PENDING
                : EvidenceEdge.ReviewStatus.APPROVED_CANDIDATE;
        return new Assessment(score, status, contradicted);
    }
    public record Assessment(double confidence, EvidenceEdge.ReviewStatus status, boolean contradicted) { }
}
