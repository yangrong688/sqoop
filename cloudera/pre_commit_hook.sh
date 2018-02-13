#!/bin/bash

set -ex

# fetch sqoop-3rdparty
GIT_THIRD_PARTY_URL="http://github.mtv.cloudera.com/Kitchen/toolchain.git"
# this is set in cloudera/test-stable.sh, but uses existing value if already set.
THIRDPARTY_LIBS="$(mktemp -d -t tmp.XXXXXXXXXX)"
function cleanup_tp {
    rm -rf "$THIRDPARTY_LIBS"
}
trap cleanup_tp EXIT
git fetch --depth=1 "$GIT_THIRD_PARTY_URL" refs/heads/master
git archive --format=tar FETCH_HEAD:fpm/sqoop_3rdparty | (cd "$THIRDPARTY_LIBS" && tar -xv)

export MAVEN3_HOME=$MAVEN_3_5_0_HOME
export JAVA8_HOME=$JAVA_1_8_HOME
export ANT_HOME=$ANT_1_9_6_HOME
export PATH=$MAVEN3_HOME/bin:$PATH

# activate mvn-gbn wrapper
mv "$(which mvn-gbn-wrapper)" "$(dirname "$(which mvn-gbn-wrapper)")/mvn"

mvn -f cloudera-pom.xml process-resources
./cloudera/test-stable.sh --build=build.xml --java=1.8 --target-java=1.8
