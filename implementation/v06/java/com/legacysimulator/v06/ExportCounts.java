package com.legacysimulator.v06;

// V6-ADD-015: 通常案件と高額案件の運用照合件数。
public record ExportCounts(int normalCount, int highCount) { }
