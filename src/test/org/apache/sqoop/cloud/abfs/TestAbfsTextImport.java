package org.apache.sqoop.cloud.abfs;

import org.apache.sqoop.cloud.AbstractTestTextImport;
import org.apache.sqoop.testcategories.thirdpartytest.AbfsTest;
import org.junit.ClassRule;
import org.junit.experimental.categories.Category;

@Category(AbfsTest.class)
public class TestAbfsTextImport extends AbstractTestTextImport {

  @ClassRule
  public static AbfsCredentialsRule credentialsRule = new AbfsCredentialsRule();

  public TestAbfsTextImport() {
    super(credentialsRule);
  }
}
