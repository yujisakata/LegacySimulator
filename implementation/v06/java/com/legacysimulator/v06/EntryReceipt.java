package com.legacysimulator.v06;

import java.util.Collections;
import java.util.List;

// V6-ADD-012: Web受付へ返す結果。Java点検を最終査定とは表現しない。
public final class EntryReceipt {
    private final boolean accepted;
    private final String applicationNumber;
    private final String batchLane;
    private final List<String> messages;

    private EntryReceipt(boolean accepted, String number, String lane, List<String> messages) {
        this.accepted = accepted;
        this.applicationNumber = number;
        this.batchLane = lane;
        this.messages = messages;
    }
    public static EntryReceipt accepted(String number, String lane) {
        return new EntryReceipt(true, number, lane, Collections.<String>emptyList());
    }
    public static EntryReceipt rejected(List<String> messages) {
        return new EntryReceipt(false, null, null, List.copyOf(messages));
    }
    public boolean isAccepted() { return accepted; }
    public String getApplicationNumber() { return applicationNumber; }
    public String getBatchLane() { return batchLane; }
    public List<String> getMessages() { return messages; }
}
