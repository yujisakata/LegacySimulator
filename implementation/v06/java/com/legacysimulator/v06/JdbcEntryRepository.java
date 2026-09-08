package com.legacysimulator.v06;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

// V6-ADD-008: Springトランザクション配下で利用する受付DBリポジトリ。
public final class JdbcEntryRepository implements EntryRepository {
    private static final String INSERT_SQL =
        "INSERT INTO ENTRY_APPLICATION " +
        "(APPLICATION_NUMBER, PRODUCT_CODE, AGE, INSURED_AMOUNT, STATUS_CODE, RECEIVED_AT) " +
        "VALUES (?, ?, ?, ?, ?, ?)";
    private static final String UPDATE_STATUS_SQL =
        "UPDATE ENTRY_APPLICATION SET STATUS_CODE=? WHERE APPLICATION_NUMBER=? AND STATUS_CODE=?";
    private static final String SELECT_ONE_SQL =
        "SELECT APPLICATION_NUMBER, PRODUCT_CODE, AGE, INSURED_AMOUNT, STATUS_CODE, RECEIVED_AT " +
        "FROM ENTRY_APPLICATION WHERE APPLICATION_NUMBER=?";
    private static final String SELECT_READY_SQL =
        "SELECT APPLICATION_NUMBER, PRODUCT_CODE, AGE, INSURED_AMOUNT, STATUS_CODE, RECEIVED_AT " +
        "FROM ENTRY_APPLICATION WHERE STATUS_CODE='READY_FOR_COBOL' ORDER BY APPLICATION_NUMBER";
    private final DataSource dataSource;

    public JdbcEntryRepository(DataSource dataSource) { this.dataSource = dataSource; }

    public void save(EntryApplication application) {
        Connection connection = null;
        PreparedStatement statement = null;
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(INSERT_SQL);
            statement.setString(1, application.getApplicationNumber());
            statement.setString(2, application.getProductCode());
            statement.setInt(3, application.getAge());
            statement.setBigDecimal(4, application.getInsuredAmount());
            statement.setString(5, application.getStatus());
            statement.setTimestamp(6, new java.sql.Timestamp(application.getReceivedAt().getTime()));
            if (statement.executeUpdate() != 1) throw new SQLException("受付登録件数が1件ではありません");
        } catch (SQLException error) {
            throw new EntryRepositoryException("受付登録に失敗しました", error);
        } finally { close(statement); close(connection); }
    }

    // V6-ADD-009: 受付番号による単一検索。状態を含めて申込集約を復元する。
    public EntryApplication find(String applicationNumber) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet result = null;
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(SELECT_ONE_SQL);
            statement.setString(1, applicationNumber);
            result = statement.executeQuery();
            return result.next() ? map(result) : null;
        } catch (SQLException error) {
            throw new EntryRepositoryException("受付検索に失敗しました", error);
        } finally { close(result); close(statement); close(connection); }
    }

    public List<EntryApplication> findReadyForCobol(int limit) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet result = null;
        List<EntryApplication> applications = new ArrayList<>();
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(SELECT_READY_SQL);
            statement.setMaxRows(limit);
            result = statement.executeQuery();
            while (result.next()) applications.add(map(result));
            return applications;
        } catch (SQLException error) {
            throw new EntryRepositoryException("COBOL連携対象の検索に失敗しました", error);
        } finally { close(result); close(statement); close(connection); }
    }

    private EntryApplication map(ResultSet result) throws SQLException {
        EntryRequest request = new EntryRequest(result.getString("APPLICATION_NUMBER"),
                result.getString("PRODUCT_CODE"), result.getInt("AGE"),
                result.getBigDecimal("INSURED_AMOUNT"));
        EntryApplication application = new EntryApplication(request, result.getTimestamp("RECEIVED_AT"));
        application.restoreStatus(result.getString("STATUS_CODE"));
        return application;
    }

    public void updateStatus(String number, String expected, String next) {
        Connection connection = null;
        PreparedStatement statement = null;
        try {
            connection = dataSource.getConnection();
            statement = connection.prepareStatement(UPDATE_STATUS_SQL);
            statement.setString(1, next);
            statement.setString(2, number);
            statement.setString(3, expected);
            if (statement.executeUpdate() != 1) throw new SQLException("状態遷移競合");
        } catch (SQLException error) {
            throw new EntryRepositoryException("状態更新に失敗しました", error);
        } finally { close(statement); close(connection); }
    }

    private void close(AutoCloseable value) {
        if (value == null) return;
        try { value.close(); } catch (Exception ignored) { }
    }
}
