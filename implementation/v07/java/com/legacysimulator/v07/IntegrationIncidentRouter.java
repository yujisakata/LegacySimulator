package com.legacysimulator.v07;

// V7-ADD-014: ベンダ共同調査の開始順を判定する運用支援ロジック。
public final class IntegrationIncidentRouter {
    public String firstAssignee(boolean javaFileExists, boolean cobolAccepted, boolean resultImported) {
        if (!javaFileExists) return "JAVA_VENDOR";
        if (!cobolAccepted) return "COBOL_VENDOR";
        if (!resultImported) return "JAVA_VENDOR";
        return "OPERATIONS";
    }
}
