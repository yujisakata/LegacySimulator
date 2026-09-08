package com.legacysimulator.v05;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.sql.DataSource;

// V5-ADD-008: 照会用複製DBだけを参照するJDBC実装。
public final class JdbcInquiryDao implements InquiryDao {
    private static final String SELECT_SQL =
            "SELECT CONTRACT_NUMBER, STATUS_CODE, INSURED_AMOUNT, AS_OF_DATE " +
            "FROM INQUIRY_SNAPSHOT WHERE CONTRACT_NUMBER = ?";
    private final DataSource dataSource;

    public JdbcInquiryDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public InquiryRecord find(String contractNumber) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet result = null;
        try {
            connection = dataSource.getConnection();
            connection.setReadOnly(true);
            statement = connection.prepareStatement(SELECT_SQL);
            statement.setString(1, contractNumber);
            result = statement.executeQuery();
            if (!result.next()) return null;
            BigDecimal amount = result.getBigDecimal("INSURED_AMOUNT");
            return new InquiryRecord(
                    result.getString("CONTRACT_NUMBER"),
                    result.getString("STATUS_CODE"),
                    amount,
                    result.getString("AS_OF_DATE"));
        } catch (SQLException error) {
            throw new InquiryDataAccessException("照会DBの取得に失敗しました", error);
        } finally {
            close(result);
            close(statement);
            close(connection);
        }
    }

    private void close(AutoCloseable resource) {
        if (resource == null) return;
        try { resource.close(); } catch (Exception ignored) {
            // V5-ADD-009: 主例外を維持し、クローズ失敗はサーバログ側で監視する。
        }
    }
}
