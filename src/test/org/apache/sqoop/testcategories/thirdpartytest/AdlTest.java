package org.apache.sqoop.testcategories.thirdpartytest;

/**
 * An Adl test shall test the integration with the Azure cloud service with the ADL file system.
 * These tests also require Adl credentials to access Azure and they run only if these
 * credentials are provided via the -Dadl.generator.command=<credential-generator-command> property
 * as well as the target Adl location via the -Dadl.container.url=<container-url> property.
 */
public interface AdlTest extends ThirdPartyTest {
}
