package com.legacysimulator.v10;

import java.util.Map;

// V10-ADD-001: Java 21解析基盤へ渡す確信度付き不変知識エッジ。
public record EvidenceEdge(
        String edgeId,
        String fromArtifact,
        String toArtifact,
        String version,
        double confidence,
        ReviewStatus status,
        Map<String, Boolean> evidence) {

    // V10-ADD-002: AI推定を自動承認しないレビュー状態。
    public enum ReviewStatus { PENDING, APPROVED_CANDIDATE }
}
