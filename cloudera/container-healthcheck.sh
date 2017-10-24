#!/bin/bash
#
# Copyright 2017 The Apache Software Foundation
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
#

EXITED_STATUS='"exited"'
HEALTHY_STATUS='"healthy"'
overallStatus=0
containers=(sqoop_mysql_container \
            sqoop_postgresql_container \
            sqoop_mssql_container \
            sqoop_cubrid_container \
            sqoop_oracle_container \
            sqoop_db2_container)

for container in ${containers[@]}; do
    containerStatus=`docker inspect --format='{{json .State.Status}}' $container`
    healthStatus=`docker inspect --format='{{json .State.Health.Status}}' $container`
    echo "$container: $containerStatus/$healthStatus"
    if [ $containerStatus == $EXITED_STATUS ] || [ $healthStatus != $HEALTHY_STATUS ]
    then
        overallStatus=1
    fi
done

exit $overallStatus
