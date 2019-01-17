/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.sqoop.cloud.abfs;

import static org.apache.hadoop.fs.azurebfs.constants.ConfigurationKeys.AZURE_SKIP_USER_GROUP_METADATA_DURING_INITIALIZATION;
import static org.apache.hadoop.fs.azurebfs.constants.ConfigurationKeys.FS_AZURE_ACCOUNT_AUTH_TYPE_PROPERTY_NAME;
import static org.apache.hadoop.fs.azurebfs.constants.ConfigurationKeys.FS_AZURE_ACCOUNT_OAUTH_CLIENT_ENDPOINT;
import static org.apache.hadoop.fs.azurebfs.constants.ConfigurationKeys.FS_AZURE_ACCOUNT_OAUTH_CLIENT_ID;
import static org.apache.hadoop.fs.azurebfs.constants.ConfigurationKeys.FS_AZURE_ACCOUNT_OAUTH_CLIENT_SECRET;
import static org.apache.hadoop.fs.azurebfs.constants.ConfigurationKeys.FS_AZURE_ACCOUNT_TOKEN_PROVIDER_TYPE_PROPERTY_NAME;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider;
import org.apache.sqoop.cloud.tools.CloudCredentialsRule;
import org.apache.sqoop.testutil.ArgumentArrayBuilder;

import java.util.Iterator;

public class AbfsCredentialsRule extends CloudCredentialsRule {

  private static final String PROPERTY_GENERATOR_COMMAND = "abfs.generator.command";

  private static final String PROPERTY_CONTAINER_URL = "abfs.container.url";

  @Override
  public void addCloudCredentialProperties(Configuration hadoopConf) {
    hadoopConf.set(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ENDPOINT, credentialsMap.get(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ENDPOINT));
    hadoopConf.set(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ID, credentialsMap.get(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ID));
    hadoopConf.set(FS_AZURE_ACCOUNT_OAUTH_CLIENT_SECRET, credentialsMap.get(FS_AZURE_ACCOUNT_OAUTH_CLIENT_SECRET));
    hadoopConf.set(FS_AZURE_ACCOUNT_AUTH_TYPE_PROPERTY_NAME, "OAuth");
    hadoopConf.set(FS_AZURE_ACCOUNT_TOKEN_PROVIDER_TYPE_PROPERTY_NAME, ClientCredsTokenProvider.class.getName());
    hadoopConf.set(AZURE_SKIP_USER_GROUP_METADATA_DURING_INITIALIZATION, "true");

    hadoopConf.set("fs.defaultFS", getBaseCloudDirectoryUrl());

    // FileSystem has a static cache that should be disabled during tests to make sure
    // Sqoop relies on the ABFS credentials set via the -D system properties.
    // For details please see SQOOP-3383
    hadoopConf.setBoolean("fs.abfs.impl.disable.cache", true);
  }

  @Override
  public void addCloudCredentialProperties(ArgumentArrayBuilder builder) {
    builder.withProperty(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ENDPOINT, credentialsMap.get(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ENDPOINT))
        .withProperty(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ID, credentialsMap.get(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ID))
        .withProperty(FS_AZURE_ACCOUNT_OAUTH_CLIENT_SECRET, credentialsMap.get(FS_AZURE_ACCOUNT_OAUTH_CLIENT_SECRET))
        .withProperty(FS_AZURE_ACCOUNT_AUTH_TYPE_PROPERTY_NAME, "OAuth")
        .withProperty(FS_AZURE_ACCOUNT_TOKEN_PROVIDER_TYPE_PROPERTY_NAME, ClientCredsTokenProvider.class.getName());
  }

  @Override
  public void addCloudCredentialProviderProperties(ArgumentArrayBuilder builder) {
    builder.withProperty("fs.abfs.impl.disable.cache", "true")
        .withProperty(FS_AZURE_ACCOUNT_AUTH_TYPE_PROPERTY_NAME, "OAuth")
        .withProperty(FS_AZURE_ACCOUNT_TOKEN_PROVIDER_TYPE_PROPERTY_NAME, ClientCredsTokenProvider.class.getName());
  }

  @Override
  public String getBaseCloudDirectoryUrl() {
    return System.getProperty(PROPERTY_CONTAINER_URL);
  }

  @Override
  protected void initializeCredentialsMap(Iterable<String> credentials) {
    Iterator<String> credentialsIterator = credentials.iterator();

    credentialsMap.put(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ENDPOINT, credentialsIterator.next());
    credentialsMap.put(FS_AZURE_ACCOUNT_OAUTH_CLIENT_ID, credentialsIterator.next());
    credentialsMap.put(FS_AZURE_ACCOUNT_OAUTH_CLIENT_SECRET, credentialsIterator.next());
  }

  @Override
  protected String getGeneratorCommand() {
    return System.getProperty(PROPERTY_GENERATOR_COMMAND);
  }
}
