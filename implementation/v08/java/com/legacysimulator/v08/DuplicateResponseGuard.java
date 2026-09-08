package com.legacysimulator.v08;

import java.util.HashSet;
import java.util.Set;

// V8-ADD-004: 接続先と取引IDの組合せで二重反映を防止する。
public final class DuplicateResponseGuard {
    private final Set<String> processed = new HashSet<>();
    public boolean accept(CanonicalResponse response) { return processed.add(response.deduplicationKey()); }
}
