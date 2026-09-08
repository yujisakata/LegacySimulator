package com.legacysimulator.v06;

import java.util.List;

// V6-ADD-007: 受付中はJava RDBを正本とするデータアクセス境界。
public interface EntryRepository {
    void save(EntryApplication application);
    EntryApplication find(String applicationNumber);
    List<EntryApplication> findReadyForCobol(int limit);
    void updateStatus(String applicationNumber, String expectedStatus, String newStatus);
}
