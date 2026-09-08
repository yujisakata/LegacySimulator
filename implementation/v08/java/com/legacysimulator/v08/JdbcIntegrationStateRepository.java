package com.legacysimulator.v08;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

// V8-ADD-009: 再送順序と状態を保持するJDBCリポジトリ。
public final class JdbcIntegrationStateRepository implements IntegrationStateRepository {
    private static final String INSERT_SQL =
        "INSERT INTO INTEGRATION_STATE " +
        "(PARTNER_CODE, TRANSACTION_ID, APPLICATION_NUMBER, REQUEST_PAYLOAD, SEQUENCE_NUMBER, STATUS_CODE, RETRY_COUNT, UPDATED_AT) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
    private static final String UPDATE_SQL =
        "UPDATE INTEGRATION_STATE SET STATUS_CODE=?, RETRY_COUNT=?, UPDATED_AT=CURRENT_TIMESTAMP " +
        "WHERE PARTNER_CODE=? AND TRANSACTION_ID=?";
    private static final String SELECT_ONE_SQL =
        "SELECT PARTNER_CODE, TRANSACTION_ID, APPLICATION_NUMBER, REQUEST_PAYLOAD, SEQUENCE_NUMBER, STATUS_CODE, RETRY_COUNT, UPDATED_AT " +
        "FROM INTEGRATION_STATE WHERE PARTNER_CODE=? AND TRANSACTION_ID=?";
    private static final String SELECT_RETRY_SQL =
        "SELECT PARTNER_CODE, TRANSACTION_ID, APPLICATION_NUMBER, REQUEST_PAYLOAD, SEQUENCE_NUMBER, STATUS_CODE, RETRY_COUNT, UPDATED_AT " +
        "FROM INTEGRATION_STATE WHERE STATUS_CODE='RETRY_WAIT' AND RETRY_COUNT<? " +
        // V8-FIX-001 DEL: "ORDER BY UPDATED_AT, TRANSACTION_ID";
        // V8-FIX-001 ADD: DB取得時点から初回キュー番号順を保証する。
        "ORDER BY SEQUENCE_NUMBER";
    private final DataSource dataSource;
    public JdbcIntegrationStateRepository(DataSource dataSource) { this.dataSource = dataSource; }

    public void create(IntegrationState state) {
        execute(INSERT_SQL, state, true);
    }
    public void save(IntegrationState state) {
        execute(UPDATE_SQL, state, false);
    }
    public IntegrationState find(String partner, String transactionId) {
        Connection connection = null; PreparedStatement statement = null; ResultSet result = null;
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(SELECT_ONE_SQL);
            statement.setString(1, partner); statement.setString(2, transactionId);
            result = statement.executeQuery();
            return result.next() ? map(result) : null;
        } catch (SQLException error) {
            throw new IntegrationPersistenceException("連携状態の検索に失敗しました", error);
        } finally { close(result); close(statement); close(connection); }
    }
    public List<IntegrationState> findRetryTargets(int maximumRetryCount, int limit) {
        Connection connection = null; PreparedStatement statement = null; ResultSet result = null;
        List<IntegrationState> states = new ArrayList<>();
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(SELECT_RETRY_SQL);
            statement.setInt(1, maximumRetryCount); statement.setMaxRows(limit);
            result = statement.executeQuery();
            while (result.next()) states.add(map(result));
            return states;
        } catch (SQLException error) {
            throw new IntegrationPersistenceException("再送対象の検索に失敗しました", error);
        } finally { close(result); close(statement); close(connection); }
    }

    private IntegrationState map(ResultSet result) throws SQLException {
        PartnerRequest request = new PartnerRequest(result.getString("APPLICATION_NUMBER"),
                result.getString("TRANSACTION_ID"), result.getString("PARTNER_CODE"),
                result.getString("REQUEST_PAYLOAD"));
        // V8-FIX-001 DEL: IntegrationState state = new IntegrationState(request);
        // V8-FIX-001 ADD: 永続化した初回キュー番号を復元する。
        IntegrationState state = new IntegrationState(request, result.getLong("SEQUENCE_NUMBER"));
        state.restore(result.getString("STATUS_CODE"), result.getInt("RETRY_COUNT"),
                result.getTimestamp("UPDATED_AT"));
        return state;
    }

    private void execute(String sql, IntegrationState state, boolean insert) {
        Connection connection = null;
        PreparedStatement statement = null;
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(sql);
            PartnerRequest request = state.getRequest();
            if (insert) {
                statement.setString(1, request.getPartner());
                statement.setString(2, request.getTransactionId());
                statement.setString(3, request.getApplicationNumber());
                statement.setString(4, request.getPayload());
                statement.setLong(5, state.getSequence());
                statement.setString(6, state.getStatus());
                statement.setInt(7, state.getRetryCount());
            } else {
                statement.setString(1, state.getStatus());
                statement.setInt(2, state.getRetryCount());
                statement.setString(3, request.getPartner());
                statement.setString(4, request.getTransactionId());
            }
            if (statement.executeUpdate() != 1) throw new SQLException("連携状態の更新件数が不正です");
        } catch (SQLException error) {
            throw new IntegrationPersistenceException("連携状態の保存に失敗しました", error);
        } finally { close(statement); close(connection); }
    }
    private void close(AutoCloseable value) { if (value != null) try { value.close(); } catch (Exception ignored) { } }
}
