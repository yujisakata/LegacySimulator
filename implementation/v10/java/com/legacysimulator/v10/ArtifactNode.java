package com.legacysimulator.v10;

import java.nio.file.Path;

// V10-ADD-011: 要件・設計・実装・テスト・運用を同じグラフで扱う資産ノード。
public record ArtifactNode(String id, ArtifactKind kind, String version, Path path, String sha256) {
    public enum ArtifactKind { REQUIREMENT, DESIGN, IMPLEMENTATION, TEST, OPERATION, DATA, LOG }
}
