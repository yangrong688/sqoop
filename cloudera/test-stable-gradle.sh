#!/bin/bash -x
#
# Copyright 2011 The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CLOUDERA_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export GRADLE_ARGUMENTS="-Dorg.gradle.daemon=false \
                         -DforkEvery.default=30 \
                         -DignoreTestFailures=true \
                         -Dsqoop.thirdparty.lib.dir=./oracledriver \
                         $GRADLE_ARGUMENTS"


sudo $CLOUDERA_DIR/../src/scripts/thirdpartytest/stop-thirdpartytest-db-containers.sh
sudo $CLOUDERA_DIR/../src/scripts/thirdpartytest/start-thirdpartytest-db-containers.sh

# Run basic unit and integration tests.
$CLOUDERA_DIR/../gradlew $GRADLE_ARGUMENTS test

if [[ $? -ne 0 ]]; then
  echo "Error executing test task. Aborting!"
  exit 1
fi

# Run thirdparty tests.
sudo $CLOUDERA_DIR/wait-for-containers.sh

if [[ $? -ne 0 ]]; then
    sudo $CLOUDERA_DIR/../src/scripts/thirdpartytest/stop-thirdpartytest-db-containers.sh
    exit 1
fi

# Only Oracle driver is needed the rest of the drivers are resolved
# from Maven repositories.
mkdir -p oracledriver
cp /sqoop-3rdparty/ojdbc6.jar ./oracledriver/

$CLOUDERA_DIR/../gradlew $GRADLE_ARGUMENTS thirdPartyTest

if [[ $? -ne 0 ]]; then
    sudo $CLOUDERA_DIR/../src/scripts/thirdpartytest/stop-thirdpartytest-db-containers.sh
    exit 1
fi
