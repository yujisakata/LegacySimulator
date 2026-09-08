package com.legacysimulator.v09;

import java.util.Map;

// V9-FIX-001 ADD: COBOL・旧Spring・Bootそれぞれの実行境界から監査ログを出す契約。
public final class GenerationAuditEmitter {
    public interface TextSink { void append(String record); }
    public interface StructuredSink { void append(Map<String, String> record); }
    private final AuditEventEncoder encoder;
    public GenerationAuditEmitter(AuditEventEncoder encoder) { this.encoder = encoder; }
    public void emitCobol(AuditEvent event, TextSink sink) { sink.append(encoder.toCobolFixed(event)); }
    public void emitLegacySpring(AuditEvent event, TextSink sink) { sink.append(encoder.toLegacySpring(event)); }
    public void emitSpringBoot(AuditEvent event, StructuredSink sink) { sink.append(encoder.toSpringBoot(event)); }
}
