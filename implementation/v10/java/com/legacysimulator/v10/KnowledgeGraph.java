package com.legacysimulator.v10;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// V10-ADD-013: ノードと確信度付きエッジを追記型で保持する解析用グラフ。
public final class KnowledgeGraph {
    private final Map<String, ArtifactNode> nodes = new HashMap<>();
    private final List<EvidenceEdge> edges = new ArrayList<>();

    public void addNode(ArtifactNode node) {
        if (nodes.putIfAbsent(node.id(), node) != null) throw new IllegalArgumentException("ノードID重複: " + node.id());
    }
    public void addEdge(EvidenceEdge edge) {
        if (!nodes.containsKey(edge.fromArtifact()) || !nodes.containsKey(edge.toArtifact())) {
            throw new IllegalArgumentException("存在しないノードへのエッジです: " + edge.edgeId());
        }
        edges.add(edge);
    }
    public List<EvidenceEdge> pendingEdges() {
        return edges.stream().filter(edge -> edge.status() == EvidenceEdge.ReviewStatus.PENDING).toList();
    }
    public Map<String, ArtifactNode> nodes() { return Collections.unmodifiableMap(nodes); }
    public List<EvidenceEdge> edges() { return Collections.unmodifiableList(edges); }
}
