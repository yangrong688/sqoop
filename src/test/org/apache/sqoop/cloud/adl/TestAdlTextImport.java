package org.apache.sqoop.cloud.adl;

import org.apache.sqoop.cloud.AbstractTestTextImport;
import org.apache.sqoop.testcategories.thirdpartytest.AdlTest;
import org.junit.ClassRule;
import org.junit.experimental.categories.Category;

@Category(AdlTest.class)
public class TestAdlTextImport extends AbstractTestTextImport {

  @ClassRule
  public static AdlCredentialsRule credentialsRule = new AdlCredentialsRule();

  public TestAdlTextImport() {
    super(credentialsRule);
  }
}
