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

package org.apache.sqoop.cloud.adl;

import static org.apache.hadoop.fs.adl.AdlConfKeys.AZURE_AD_CLIENT_ID_KEY;
import static org.apache.hadoop.fs.adl.AdlConfKeys.AZURE_AD_CLIENT_SECRET_KEY;
import static org.apache.hadoop.fs.adl.AdlConfKeys.AZURE_AD_REFRESH_URL_KEY;
import static org.apache.hadoop.fs.adl.AdlConfKeys.AZURE_AD_TOKEN_PROVIDER_TYPE_KEY;
import static org.apache.hadoop.fs.adl.AdlConfKeys.TOKEN_PROVIDER_TYPE_CLIENT_CRED;

import org.apache.hadoop.conf.Configuration;
import org.apache.sqoop.cloud.tools.CloudCredentialsRule;
import org.apache.sqoop.testutil.ArgumentArrayBuilder;

import java.util.Iterator;

public class AdlCredentialsRule extends CloudCredentialsRule {

  private static final String PROPERTY_GENERATOR_COMMAND = "adl.generator.command";

  private static final String PROPERTY_CONTAINER_URL = "adl.container.url";

  @Override
  public void addCloudCredentialProperties(Configuration hadoopConf) {
    hadoopConf.set(AZURE_AD_REFRESH_URL_KEY, credentialsMap.get(AZURE_AD_REFRESH_URL_KEY));
    hadoopConf.set(AZURE_AD_CLIENT_ID_KEY, credentialsMap.get(AZURE_AD_CLIENT_ID_KEY));
    hadoopConf.set(AZURE_AD_CLIENT_SECRET_KEY, credentialsMap.get(AZURE_AD_CLIENT_SECRET_KEY));
    hadoopConf.set(AZURE_AD_TOKEN_PROVIDER_TYPE_KEY, TOKEN_PROVIDER_TYPE_CLIENT_CRED);

    hadoopConf.set("fs.defaultFS", getBaseCloudDirectoryUrl());

    hadoopConf.setBoolean("fs.adl.impl.disable.cache", true);
  }

  @Override
  public void addCloudCredentialProperties(ArgumentArrayBuilder builder) {
    builder.withProperty(AZURE_AD_REFRESH_URL_KEY, credentialsMap.get(AZURE_AD_REFRESH_URL_KEY))
        .withProperty(AZURE_AD_CLIENT_ID_KEY, credentialsMap.get(AZURE_AD_CLIENT_ID_KEY))
        .withProperty(AZURE_AD_CLIENT_SECRET_KEY, credentialsMap.get(AZURE_AD_CLIENT_SECRET_KEY))
        .withProperty(AZURE_AD_TOKEN_PROVIDER_TYPE_KEY, TOKEN_PROVIDER_TYPE_CLIENT_CRED);
  }

  @Override
  public void addCloudCredentialProviderProperties(ArgumentArrayBuilder builder) {
    builder.withProperty("fs.adl.impl.disable.cache", "true")
        .withProperty(AZURE_AD_TOKEN_PROVIDER_TYPE_KEY, TOKEN_PROVIDER_TYPE_CLIENT_CRED);
  }

  @Override
  public String getBaseCloudDirectoryUrl() {
    return System.getProperty(PROPERTY_CONTAINER_URL);
  }

  @Override
  protected void initializeCredentialsMap(Iterable<String> credentials) {
    Iterator<String> credentialsIterator = credentials.iterator();

    credentialsMap.put(AZURE_AD_REFRESH_URL_KEY, credentialsIterator.next());
    credentialsMap.put(AZURE_AD_CLIENT_ID_KEY, credentialsIterator.next());
    credentialsMap.put(AZURE_AD_CLIENT_SECRET_KEY, credentialsIterator.next());
  }

  @Override
  protected String getGeneratorCommand() {
    return System.getProperty(PROPERTY_GENERATOR_COMMAND);
  }
}
