package com.legacysimulator.v10;

import java.util.List;

// V10-ADD-015: 現行動作と望ましい動作を混同しない調査結果。
public record ModernizationFinding(
        String businessRuleId,
        String observedBehavior,
        String desiredBehavior,
        List<String> evidenceEdgeIds,
        DecisionState decisionState) {
    public enum DecisionState { UNREVIEWED, CURRENT_BEHAVIOR_APPROVED, CHANGE_APPROVED }
}
