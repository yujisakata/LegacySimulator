package com.legacysimulator.v05;

import java.io.BufferedReader;
import java.io.FileReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.sql.DataSource;

// V5-ADD-011: COBOL固定長を照会用複製DBへロードする夜間専用処理。
// Web照会プロセスからは呼び出さず、INQSYNCジョブだけが実行する。
public final class SnapshotImportJob {
    private static final String DELETE_SNAPSHOT = "DELETE FROM INQUIRY_SNAPSHOT";
    private static final String INSERT_SNAPSHOT =
            "INSERT INTO INQUIRY_SNAPSHOT " +
            "(CONTRACT_NUMBER, STATUS_CODE, INSURED_AMOUNT, AS_OF_DATE) " +
            "VALUES (?, ?, ?, ?)";
    private final DataSource dataSource;
    private final FixedLengthInquiryConverter converter;

    public SnapshotImportJob(DataSource dataSource, FixedLengthInquiryConverter converter) {
        this.dataSource = dataSource;
        this.converter = converter;
    }

    public int execute(String inputPath) throws Exception {
        Connection connection = dataSource.getConnection();
        BufferedReader reader = null;
        PreparedStatement delete = null;
        PreparedStatement insert = null;
        int count = 0;
        try {
            connection.setAutoCommit(false);
            delete = connection.prepareStatement(DELETE_SNAPSHOT);
            delete.executeUpdate();
            insert = connection.prepareStatement(INSERT_SNAPSHOT);
            reader = new BufferedReader(new FileReader(inputPath));
            String line;
            while ((line = reader.readLine()) != null) {
                InquiryRecord record = converter.convert(line);
                bind(insert, record);
                insert.addBatch();
                count++;
                if (count % 500 == 0) insert.executeBatch();
            }
            insert.executeBatch();
            connection.commit();
            return count;
        } catch (Exception error) {
            rollback(connection);
            throw error;
        } finally {
            close(reader);
            close(insert);
            close(delete);
            close(connection);
        }
    }

    private void bind(PreparedStatement statement, InquiryRecord record) throws SQLException {
        statement.setString(1, record.getContractNumber());
        statement.setString(2, record.getStatus());
        statement.setBigDecimal(3, record.getInsuredAmount());
        statement.setString(4, record.getAsOfDate());
    }

    private void rollback(Connection connection) {
        try { connection.rollback(); } catch (SQLException ignored) { }
    }

    private void close(AutoCloseable resource) {
        if (resource == null) return;
        try { resource.close(); } catch (Exception ignored) { }
    }
}
