package com.legacysimulator.v09;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

// V9-ADD-010: 元時刻・オフセット・UTCを同時保存する監査DB実装。
public final class JdbcAuditRepository implements AuditRepository {
    private static final String INSERT_SQL =
        "INSERT INTO AUDIT_EVENT (SOURCE_SYSTEM, TRANSACTION_KEY, OPERATOR_ID, INPUT_DIGEST, " +
        "REASON_CODE, ORIGINAL_TIME, ORIGINAL_OFFSET, OCCURRED_AT_UTC) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    private final DataSource dataSource;
    private static final String SELECT_SQL =
        "SELECT SOURCE_SYSTEM, TRANSACTION_KEY, OPERATOR_ID, INPUT_DIGEST, REASON_CODE, " +
        "ORIGINAL_TIME, ORIGINAL_OFFSET FROM AUDIT_EVENT " +
        "WHERE TRANSACTION_KEY=? AND OCCURRED_AT_UTC>=? AND OCCURRED_AT_UTC<? ORDER BY OCCURRED_AT_UTC";
    public JdbcAuditRepository(DataSource dataSource) { this.dataSource = dataSource; }

    public boolean appendIfAbsent(AuditEvent event) {
        Connection connection = null;
        PreparedStatement statement = null;
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(INSERT_SQL);
            statement.setString(1, event.sourceSystem());
            statement.setString(2, event.transactionKey());
            statement.setString(3, event.operatorId());
            statement.setString(4, event.inputDigest());
            statement.setString(5, event.reasonCode());
            statement.setString(6, event.occurredAt().toLocalDateTime().toString());
            statement.setString(7, event.occurredAt().getOffset().toString());
            statement.setTimestamp(8, java.sql.Timestamp.from(event.occurredAt().toInstant()));
            return statement.executeUpdate() == 1;
        } catch (SQLException duplicateOrFailure) {
            // V9-ADD-011: 一意キー重複は夜間再集約の既処理として扱う。
            if ("23505".equals(duplicateOrFailure.getSQLState())) return false;
            throw new AuditPersistenceException("監査イベント保存に失敗しました", duplicateOrFailure);
        } finally { close(statement); close(connection); }
    }
    public List<AuditEvent> find(String key, Instant from, Instant to) {
        Connection connection = null; PreparedStatement statement = null; ResultSet result = null;
        List<AuditEvent> events = new ArrayList<>();
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(SELECT_SQL);
            statement.setString(1, key);
            statement.setTimestamp(2, java.sql.Timestamp.from(from));
            statement.setTimestamp(3, java.sql.Timestamp.from(to));
            result = statement.executeQuery();
            while (result.next()) {
                OffsetDateTime occurredAt = OffsetDateTime.parse(
                        result.getString("ORIGINAL_TIME") + result.getString("ORIGINAL_OFFSET"));
                events.add(new AuditEvent(result.getString("SOURCE_SYSTEM"),
                        result.getString("TRANSACTION_KEY"), result.getString("OPERATOR_ID"),
                        result.getString("INPUT_DIGEST"), result.getString("REASON_CODE"), occurredAt));
            }
            return events;
        } catch (SQLException error) {
            throw new AuditPersistenceException("監査イベント検索に失敗しました", error);
        } finally { close(result); close(statement); close(connection); }
    }
    private void close(AutoCloseable value) { if (value != null) try { value.close(); } catch (Exception ignored) { } }
}
