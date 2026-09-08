package com.legacysimulator.v09;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

// V9-FIX-002 ADD: 業務結果とOutbox要求を同一DBトランザクションで確定する。
public final class JdbcKycOutboxRepository implements KycOutboxRepository {
    private static final String INSERT_RESULT =
            "INSERT INTO KYC_RESULT (TRANSACTION_KEY, RESULT_CODE) VALUES (?, ?)";
    private static final String INSERT_OUTBOX =
            "INSERT INTO KYC_OUTBOX (TRANSACTION_KEY, RESULT_CODE, AUDIT_REASON, PUBLISHED_FLAG, CREATED_AT) "
            + "VALUES (?, ?, ?, 'N', CURRENT_TIMESTAMP)";
    private static final String SELECT_UNPUBLISHED =
            "SELECT TRANSACTION_KEY, RESULT_CODE FROM KYC_OUTBOX WHERE PUBLISHED_FLAG='N' "
            + "ORDER BY CREATED_AT, TRANSACTION_KEY";
    private static final String MARK_PUBLISHED =
            "UPDATE KYC_OUTBOX SET PUBLISHED_FLAG='Y', PUBLISHED_AT=CURRENT_TIMESTAMP "
            + "WHERE TRANSACTION_KEY=? AND PUBLISHED_FLAG='N'";
    private final DataSource dataSource;
    public JdbcKycOutboxRepository(DataSource dataSource) { this.dataSource = dataSource; }

    public boolean saveResultAndOutbox(String key, String result, String reason) {
        Connection connection = null;
        PreparedStatement resultStatement = null;
        PreparedStatement outboxStatement = null;
        try {
            connection = dataSource.getConnection();
            connection.setAutoCommit(false);
            resultStatement = connection.prepareStatement(INSERT_RESULT);
            resultStatement.setString(1, key); resultStatement.setString(2, result);
            resultStatement.executeUpdate();
            outboxStatement = connection.prepareStatement(INSERT_OUTBOX);
            outboxStatement.setString(1, key); outboxStatement.setString(2, result);
            outboxStatement.setString(3, reason); outboxStatement.executeUpdate();
            connection.commit();
            return true;
        } catch (SQLException error) {
            rollback(connection);
            if ("23505".equals(error.getSQLState())) return false;
            throw new AuditPersistenceException("本人確認結果とOutboxの保存に失敗しました", error);
        } finally { close(outboxStatement); close(resultStatement); close(connection); }
    }

    public void markPublished(String key) {
        Connection connection = null; PreparedStatement statement = null;
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(MARK_PUBLISHED);
            statement.setString(1, key); statement.executeUpdate();
        } catch (SQLException error) {
            throw new AuditPersistenceException("Outbox発行済み更新に失敗しました", error);
        } finally { close(statement); close(connection); }
    }

    public List<OutboxMessage> findUnpublished(int limit) {
        Connection connection = null; PreparedStatement statement = null; ResultSet result = null;
        List<OutboxMessage> messages = new ArrayList<>();
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(SELECT_UNPUBLISHED);
            statement.setMaxRows(limit);
            result = statement.executeQuery();
            while (result.next()) messages.add(new OutboxMessage(
                    result.getString("TRANSACTION_KEY"), result.getString("RESULT_CODE")));
            return messages;
        } catch (SQLException error) {
            throw new AuditPersistenceException("未発行Outboxの検索に失敗しました", error);
        } finally { close(result); close(statement); close(connection); }
    }

    private void rollback(Connection connection) {
        if (connection != null) try { connection.rollback(); } catch (SQLException ignored) { }
    }
    private void close(AutoCloseable value) { if (value != null) try { value.close(); } catch (Exception ignored) { } }
}
