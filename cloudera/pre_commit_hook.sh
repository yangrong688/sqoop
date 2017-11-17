#!/bin/bash
export MAVEN3_HOME=$MAVEN_3_5_0_HOME
export JAVA7_HOME=$JAVA_1_7_HOME
export ANT_HOME=$ANT_1_9_6_HOME
./cloudera/test-stable.sh --build=build.xml --java=1.7 --target-java=1.7
