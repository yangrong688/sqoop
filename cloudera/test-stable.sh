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
#
# Compiles the world and runs available unit tests.
# This script is intended for execution by users who want to thoroughly
# execute all tests, or automated testing agents such as Hudson.

# Environment:
# See test-config.sh

#bin=`readlink -f $0`
#bin=`dirname ${bin}`
#bin=`cd ${bin} && pwd`
#source ${bin}/test-config.sh


# Setup Java specific variables like Java options as well as source and target specifiers. Assumes that
# JAVA7_HOME and optionally JAVA8_HOME is defined. Hence this should only be invoked when TOOLCHAIN_HOME
# is set.
#
# Takes the the following arguments
# JAVA_VERSION - the source version
#
# The outcome is that the following variables is defined
# JAVA_HOME - The home directory of Java
# JAVA_VERSION - the source Java version
# MAVEN_OPTS - Java specific maven flags
function setupJava() {
  local _JAVA_VERSION=$1

  case ${_JAVA_VERSION} in
    1.7)
      MAVEN_OPTS="-Xmx1g -Xms128m -XX:MaxPermSize=512m"
      JAVA_OPTS="-Xmx4g -Xms1g -XX:MaxPermSize=512m"
      if [[ -z $JAVA7_HOME ]]; then
        echo JAVA7_HOME is not set
        exit 1
      fi
      JAVA_HOME=${JAVA7_HOME}
      JAVA_VERSION=1.7
      ;;

    1.8)
      MAVEN_OPTS="-Xmx1g -Xms128m"
      JAVA_OPTS="-Xmx4g -Xms1g"
      if [[ -z $JAVA8_HOME ]]; then
        echo JAVA8_HOME is not set
        exit 1
      fi
      JAVA_HOME=${JAVA8_HOME}
      JAVA_VERSION=1.8
      ;;

    *)
      echo Unknown Java version ${_JAVA_VERSION}
      exit 1
      ;;
  esac

  echo -----------------------
  echo Source Java ${JAVA_VERSION} version
  echo -----------------------

  PATH=${JAVA_HOME}/bin:$PATH

  echo
  echo ---- Java version -----
  java -version
  echo -----------------------
}


function ensureDirectory() {
  local _DIR=$1
  local _MESSAGE=$2

  if [[ ! -d ${_DIR} ]]; then
    echo ${_MESSAGE}
    exit 1
  fi
}

# Ensures that the specified command is configured on the PATH.
# Takes the following arguments
#
# CMD - The command to check
# MESSAGE - The message to write if the command is missing
function ensureCommand() {
  local _CMD=$1
  local _MESSAGE=$2

  which $_CMD >> /dev/null
  local _EXTCODE=$?

  if [[ $_EXTCODE -ne 0 ]]; then
    echo $_MESSAGE
    exit $_EXTCODE
  fi
}

# Checks if a tool chain has been set. If set then the common environment will be setup.
# The tool chain is identified by the environment variable TOOLCHAIN_HOME it is expected
# to contain the necessary tools to produce the build. As a result PATH and other key
# environment variables will be setup according to the tool chain.
#
# Takes two arguments
# JAVA_VERSION - the source Java compiler
# TOOLCHAIN_HOME - (Optional) if not empty initialize using the toolchain environment
function setupToolChain() {
  local _JAVA_VERSION=$1
  local _TOOLCHAIN_HOME=$2

  if [[ ${_TOOLCHAIN_HOME} ]];  then
    echo -----------------------
    echo Using toolchain environment ${_TOOLCHAIN_HOME}
    echo -----------------------
    ensureDirectory ${_TOOLCHAIN_HOME} "TOOLCHAIN_HOME (${_TOOLCHAIN_HOME}) does not exist or is not a directory"

    if [[ -z ${ANT_HOME} ]]; then
      echo ANT_HOME is not set
      exit 1
    fi
    ensureDirectory ${ANT_HOME} "ANT_HOME (${ANT_HOME}) does not exist or is not a directory"

    if [[ -z ${MAVEN3_HOME} ]]; then
      echo MAVEN3_HOME is not set
      exit 1
    fi
    ensureDirectory ${MAVEN3_HOME} "MAVEN3_HOME (${MAVEN3_HOME}) does not exist or is not a directory"

    # append MAVEN and ANT to PATH
    PATH=${MAVEN3_HOME}/bin:${ANT_HOME}/bin:${PATH}:${PROTOC5_HOME}/bin

    setupJava ${_JAVA_VERSION}
fi

  ensureCommand "javac" "Unable to execute javac (make sure that JAVA_HOME/PATH points to a JDK)"
  ensureCommand "mvn" "Unable to execute mvn"
  ensureCommand "ant" "Unable to execute ant"

  setupAntFlags ${_TOOLCHAIN_HOME}
}

# Setup the Java generated class files for specific VM version.
# The supported versions include 1.7 & 1.8. If the target version
# is successful then TARGET_JAVA_VERSION will be setup correctly.
#
# Takes the following arguments:
# TARGET-JAVA_VERSION - the target version
function setupJavaTarget() {
  local _TARGET_JAVA=$1

  case ${_TARGET_JAVA} in
    1.7|1.8)
      echo
      echo -----------------------
      echo Target Java ${_TARGET_JAVA} version
      echo -----------------------
      TARGET_JAVA_VERSION=${_TARGET_JAVA}
      ;;

    *)
      echo Unknown target Java version ${_TARGET_JAVA}
      exit 1
      ;;
  esac
}

function setupAntFlags() {

 ANT_ARGUMENTS="-DjavaVersion=$JAVA_VERSION -DtargetJavaVersion=$TARGET_JAVA_VERSION -Dmaxmemory=2048m -Djava.security.egd=file:///dev/./urandom -Dsqoop.test.mysql.connectstring.host_url=jdbc:mysql://mysql.vpc.cloudera.com/ -Dsqoop.test.oracle.connectstring=jdbc:oracle:thin:@//oracle-ee.vpc.cloudera.com/orcl -Dsqoop.test.postgresql.connectstring.host_url=jdbc:postgresql://postgresql.vpc.cloudera.com/ -Dsqoop.test.cubrid.connectstring.host_url=jdbc:cubrid:cubrid.vpc.cloudera.com:33000 -Dsqoop.test.cubrid.connectstring.username=sqoop -Dsqoop.test.cubrid.connectstring.database=sqoop -Dsqoop.test.cubrid.connectstring.password=sqoop -Dmapred.child.java.opts=-Djava.security.egd=file:/dev/../dev/urandom -Dtest.timeout=1000000"

}

function printUsage() {
  echo Usage:
  echo "test-stable.sh --java=<1.7(default)|1.8> --target-java=<1.7(default)|1.8> --build=<pom path> --no-build=<true|false(default)>"
  echo "       --toolchain-home=<toolchain directory> --test-fork-count=<number>"
  echo "       --test-fork-reuse=<true(default)|false> --test-set=<include-file>"
  echo
  echo "This script is intended to be invoked by one of the proxy scripts: build.sh, test-all.sh, test-code-coverage.sh, "
  echo "test-flaky.sh, test-stable.sh or test-set.sh"
  echo
  echo "Assuming this script is running under Jenkins and with toolkit env defining the following environment variables"
  echo "- ANT_HOME"
  echo "- MAVEN3_HOME"
  echo "- JAVA7_HOME"
  echo "- JAVA8_HOME (optional only needed when using Java 8)"
  echo
  echo "If WORKSPACE is not defined by environment, the current working directory is used as the WORKSPACE."
  echo "The result of parsing arguments, is that the following environment variables gets assigned:"
  echo "- BUILD -- the build.xml that will be used to drive build/testing"
  echo "- JAVA -- the Java source version"
  echo "- TARGET_JAVA -- the Java target byte code version"
  echo "- JAVA_HOME -- the home directory of the chosen Java"
  echo "- ANT_ARGUMENTS -- the Ant flags, options and properties"
  echo "- JAVA_OPTS -- Java flags"
  echo "- MAVEN_OPTS -- Maven options"
  echo
  echo "Optionally the following variables could be set"
  echo "- NO_BUILD -- iff set to true no pre-build will be performed"
  echo
  echo "About exclude and include files"
  echo
  echo "The format of the exclude/include files is defined by Maven Surefire which is a line based format."
  echo "Each line represents one or more classes to exclude or include, some special characters are allowed:"
  echo "- Lines where the first character is a '#' is considered a comment"
  echo "- Empty lines are allowed."
  echo "- '**/' is a path wildcard"
  echo "- '.*' is a file ending wildcard, otherwise .class is assumed"
  echo "- if a line contains a '#', the expression on the right of the '#' is treated as a method name"
  echo
  echo "The default exclude file for test-stable.sh and test-code-coverage.sh is 'excludes.txt'. Since some tests are"
  echo "more prone to fail during code coverage, an additional exclude file 'code-coverage-excludes.txt' is available."
  echo "This file specifies tests which that are only to be excluded during code coverage runs."
  echo
  echo "To run a custom selected set of tests, use test-set.sh and specify which tests in a include file using the "
  echo "--test-set switch."
}

# Assuming this script is running under Jenkins and with toolkit env defining the following environment variables
# - ANT_HOME
# - MAVEN3_HOME
# - JAVA7_HOME
# - JAVA8_HOME
#
#If WORKSPACE is not defined by environment, the current working directory is used as the WORKSPACE.
#The result of parsing arguments, is that the following environment variables gets assigned:
# - JAVA_VERSION -- the Java source version
# - TARGET_JAVA -- the Java target byte code version
# - JAVA_HOME -- the home directory of the chosen Java
# - ANT_ARGUMENTS -- the Ant flags, options and properties
# - JAVA_OPTS -- Java flags

function initialize() {
	
 # WORKSPACE is normally set by Jenkins
  if [[ -z "${WORKSPACE}" ]]; then
    export WORKSPACE=`pwd`
  fi

  # Set default values for generic tools
  TEST_FORK_COUNT=1
  TEST_REUSE_FORKS=true
  JAVA_VERSION=1.7
 ANT='ant'
  TARGET_JAVA=${JAVA_VERSION}
  for arg in "$@"
  do
  case ${arg} in
    --java=*)
      JAVA_VERSION="${arg#*=}"
      shift
      ;;

    --target-java=*)
      TARGET_JAVA="${arg#*=}"
      shift
      ;;

    --build=*|-p=*)
    BUILD="${arg#*=}"
      shift
      ;;

    --no-build=*)
      NO_BUILD="${arg#*=}"
      ;;

    --no-build)
      export NO_BUILD=true
      ;;

    --test-fork-count=*)
      TEST_FORK_COUNT="${arg#*=}"
      shift
      ;;

    --test-reuse-forks=*|--test-reuse-fork=*)
      TEST_REUSE_FORKS="${arg#*=}"
      shift
      ;;

   --toolchain-home=*|--tc-home=*)
      TOOLCHAIN_HOME="${arg#*=}"
      shift
      ;;

    --help|-h)
      printUsage
      exit 0
      ;;

    --script=*)
      SCRIPT="${arg#*=}"
      shift
      ;;

    --test-set=*|-tests=*)
      TEST_SET="${arg#*=}"
      shift
      ;;

    *)
      echo Unknown flag ${arg}
      ;;
  esac
  done

 IVY_HOME=$WORKSPACE/.ivy2
 COMPILE_HADOOP_DIST=cloudera
 COBERTURA_HOME=/home/hudson/lib/cobertura
 FINDBUGS_HOME=/home/hudson/lib/findbugs
 THIRDPARTY_LIBS=$TOOLCHAIN_HOME/sqoop-3rdparty
 TEST_HADOOP_DIST=cloudera
 ZOOKEEPER_HOME=/home/hudson/lib/zookeeper
 HBASE_HOME=/home/hudson/lib/hbase


  # WORKSPACE is normally set by Jenkins
  if [[ -z "${WORKSPACE}" ]]; then
    export WORKSPACE=`pwd`
  fi

  # always set the target java version
  setupJavaTarget ${TARGET_JAVA}
  # if toolchain is defined or specified use it to initialize the environment
  setupToolChain ${JAVA_VERSION} ${TOOLCHAIN_HOME}
  export PATH
 echo $PATH
echo $THIRDPARTY_LIBS
}

################################### Main section ###################################

main() {
  CLOUDERA_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  NAME=`basename $0`

 
  # script is passed to ensure arguments are compatible
initialize $@
pushd `pwd`/cloudera/maven-packaging >> /dev/null
 mvn -N install
popd >>/dev/null

  pushd `pwd` >> /dev/null
  cd ${CLOUDERA_DIR}/..

  # Run compilation step.
 
${ANT} clean jar -Divy.home=$IVY_HOME -Dhadoop.dist=${COMPILE_HADOOP_DIST} \
    ${ANT_ARGUMENTS}
if [ "$?" != "0" ]; then
  echo "Error during compilation phase. Aborting!"
  exit 1
fi

# Run basic unit tests.

${ANT} clean-cache test -Divy.home=$IVY_HOME -Dtest.junit.output.format=xml \
    -Dhadoop.dist=${TEST_HADOOP_DIST} ${ANT_ARGUMENTS}

# Run thirdparty integration unit tests.

if [ "${THIRDPARTY_LIBS}" == "" ]; then
  echo "Warning: $$THIRDPARTY_LIBS not set."
fi

${ANT} test -Dthirdparty=true -Dsqoop.thirdparty.lib.dir=${THIRDPARTY_LIBS} \
    -Dtest.junit.output.format=xml -Divy.home=$IVY_HOME \
    -Dhadoop.dist=${TEST_HADOOP_DIST} ${ANT_ARGUMENTS}

# If we got at this point, then all tests were executed properly (but might have failed), so we return success
# and let jenkins turn the job status to yellow if there are test failures

  popd >> /dev/null
}
main "$@"

