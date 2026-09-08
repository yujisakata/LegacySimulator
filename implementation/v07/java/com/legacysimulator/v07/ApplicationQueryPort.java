package com.legacysimulator.v07;

import java.util.List;

// V7-ADD-007: 二重モデルのうちJava受付DBを読む共通Service境界。
public interface ApplicationQueryPort {
    ApplicationSummary find(String applicationNumber);
    List<ApplicationSummary> findByAgency(String agencyId, int limit);
}
