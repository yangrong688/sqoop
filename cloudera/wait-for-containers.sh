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

BASEDIR=$(dirname "$0")
MAX_ITERATIONS=20
iterations=0

$BASEDIR/container-healthcheck.sh

while [ $? != 0 ] && [ $iterations -lt $MAX_ITERATIONS ]; do
   iterations=$((iterations+1))
   sleep 60
   echo $iterations
   $BASEDIR/container-healthcheck.sh
done

if [ $iterations -eq $MAX_ITERATIONS ]
then
    echo "Container healthcheck timed out, at least one of the containers could not start up correctly."
    exit 1
else
    echo "Containers started up successfully!"
    exit 0
fi
