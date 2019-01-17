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

import org.apache.sqoop.cloud.AbstractTestIncrementalMergeParquetImport;
import org.apache.sqoop.testcategories.thirdpartytest.AdlTest;
import org.junit.ClassRule;
import org.junit.experimental.categories.Category;

@Category(AdlTest.class)
public class TestAdlIncrementalMergeParquetImport extends AbstractTestIncrementalMergeParquetImport {

  @ClassRule
  public static AdlCredentialsRule credentialsRule = new AdlCredentialsRule();

  public TestAdlIncrementalMergeParquetImport() {
    super(credentialsRule);
  }

}
