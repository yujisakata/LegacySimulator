package com.legacysimulator.v08;

import java.util.List;

// V8-ADD-008: 受付と外部応答の間を永続化する境界。
public interface IntegrationStateRepository {
    void create(IntegrationState state);
    IntegrationState find(String partner, String transactionId);
    void save(IntegrationState state);
    List<IntegrationState> findRetryTargets(int maximumRetryCount, int limit);
}
