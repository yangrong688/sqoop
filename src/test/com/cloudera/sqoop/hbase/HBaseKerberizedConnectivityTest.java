package com.cloudera.sqoop.hbase;

import junit.framework.JUnit4TestAdapter;
import org.apache.sqoop.infrastructure.kerberos.MiniKdcInfrastructureRule;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import java.io.IOException;

@RunWith(JUnit4.class)
public class HBaseKerberizedConnectivityTest extends HBaseTestCase {

  private static final String HBASE_TABLE_NAME = "KerberosTest";
  private static final String HBASE_COLUMN_FAMILY = "TestColumnFamily";
  private static final String TEST_ROW_KEY = "0";
  private static final String TEST_ROW_VALUE = "1";
  private static final String[] COLUMN_TYPES = { "INT", "INT" };

  @ClassRule
  public static MiniKdcInfrastructureRule miniKdcInfrastructure = new MiniKdcInfrastructureRule();

  public HBaseKerberizedConnectivityTest() {
    super(miniKdcInfrastructure);
  }

  @Test
  public void testSqoopImportWithKerberizedHBaseConnectivitySucceeds() throws IOException {
    String[] argv = getArgv(true, HBASE_TABLE_NAME, HBASE_COLUMN_FAMILY, true, null);
    createTableWithColTypes(COLUMN_TYPES, new String[] { TEST_ROW_KEY, TEST_ROW_VALUE });

    runImport(argv);

    verifyHBaseCell(HBASE_TABLE_NAME, TEST_ROW_KEY, HBASE_COLUMN_FAMILY, getColName(1), TEST_ROW_VALUE);
  }

  public static junit.framework.Test suite() {
    return new JUnit4TestAdapter(HBaseKerberizedConnectivityTest.class);
  }
}
