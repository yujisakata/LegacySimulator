package com.legacysimulator.v05;

import java.sql.*;
import javax.sql.DataSource;

/** V5-ADD-003: Web用SELECT権限接続。公開メタデータと行を同じSQLで読む。 */
public final class JdbcInquiryDao {
    private final DataSource source;
    public JdbcInquiryDao(DataSource source) { this.source=source; }
    public InquiryRecord find(String number) throws SQLException {
        try(Connection c=source.getConnection()) {
            c.setReadOnly(true);
            try(PreparedStatement st=c.prepareStatement("SELECT S.AS_OF AS PUBLISHED_DATE,R.* FROM INQUIRY_STATE S LEFT JOIN INQUIRY_SNAPSHOT R ON R.APP_NUMBER=? WHERE S.ID=1")) {
                st.setString(1,number);
                try(ResultSet rs=st.executeQuery()) {
                    if(!rs.next() || rs.getDate("PUBLISHED_DATE")==null) throw new SQLException("Snapshot not published");
                    if(rs.getString("APP_NUMBER")==null) return null;
                    return new InquiryRecord(rs.getString("APP_NUMBER"),rs.getString("PRODUCT"),rs.getString("STATUS"),rs.getBigDecimal("AMOUNT"),rs.getDate("RESPONSIBILITY_DATE"),rs.getDate("PROCESS_DATE"),rs.getDate("RECEIPT_DATE"),rs.getString("RULE_CODE"),rs.getDate("APPLIED_DATE"),rs.getDate("PUBLISHED_DATE"),rs.getString("REASON"),rs.getString("APPROVAL"));
                }
            }
        }
    }
}
