package org.apache.sqoop.testcategories.thirdpartytest;

/**
 * An Abfs test shall test the integration with the Azure cloud service.
 * These tests also require Abfs credentials to access Azure and they run only if these
 * credentials are provided via the -Dabfs.generator.command=<credential-generator-command> property
 * as well as the target Abfs location via the -Dabfs.container.url=<container-url> property.
 */
public interface AbfsTest extends ThirdPartyTest {
}
