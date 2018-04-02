#!/bin/bash
#
# Copyright (c) 2015 The Opencron Project
# <p>
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
# <p>
# http://www.apache.org/licenses/LICENSE-2.0
# <p>
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

#echo color
WHITE_COLOR="\E[1;37m";
RED_COLOR="\E[1;31m";
BLUE_COLOR='\E[1;34m';
GREEN_COLOR="\E[1;32m";
YELLOW_COLOR="\E[1;33m";
RES="\E[0m";

printf "${GREEN_COLOR}                                                                  \n"
printf "${GREEN_COLOR}                                                      __ _ _      \n"
printf "${GREEN_COLOR}  /\     ____  ____  ___  ____  ______________  ____  \ \ \ \     \n"
printf "${GREEN_COLOR} (())   / __ \/ __ \/ _ \/ __ \/ ___/ ___/ __ \/ __ \  \ \ \ \    \n"
printf "${GREEN_COLOR}  \/   / /_/ / /_/ /  __/ / / / /__/ /  / /_/ / / / /   ) ) ) )   \n"
printf "${GREEN_COLOR}       \____/ .___/\___/_/ /_/\___/_/   \____/_/ /_/   / / / /    \n"
printf "${GREEN_COLOR}           /_/     ::opencron::(v1.2.0 RELEASE)       /_/_/_/     \n"
printf "${GREEN_COLOR}                                                                  \n"


echo_r () {
    # Color red: Error, Failed
    [ $# -ne 1 ] && return 1
    printf "[${BLUE_COLOR}opencron${RES}] ${RED_COLOR}$1${RES}\n"
}

echo_g () {
    # Color green: Success
    [ $# -ne 1 ] && return 1
    printf "[${BLUE_COLOR}opencron${RES}] ${GREEN_COLOR}$1${RES}\n"
}

echo_y () {
    # Color yellow: Warning
    [ $# -ne 1 ] && return 1
    printf "[${BLUE_COLOR}opencron${RES}] ${YELLOW_COLOR}$1${RES}\n"
}

echo_w () {
    # Color yellow: White
    [ $# -ne 1 ] && return 1
    printf "[${BLUE_COLOR}opencron${RES}] ${WHITE_COLOR}$1${RES}\n"
}

# OS specific support.  $var _must_ be set to either true or false.
cygwin=false
darwin=false
os400=false
case "`uname`" in
CYGWIN*) cygwin=true;;
Darwin*) darwin=true;;
OS400*) os400=true;;
esac

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
############################################################################################
PRGDIR=`dirname "$PRG"`                                                                   ##
WORKDIR=`cd "$PRGDIR" >/dev/null; pwd`;                                                   ##
OPENCRON_VERSION="1.2.0-RELEASE";                                                         ##
OPENCRON_AGENT=${WORKDIR}/opencron-agent/target/opencron-agent-${OPENCRON_VERSION}.tar.gz ##
OPENCRON_SERVER=${WORKDIR}/opencron-server/target/opencron-server-${OPENCRON_VERSION}.war ##
DIST_HOME="${WORKDIR}/dist"                                                               ##
############################################################################################

# Make sure prerequisite environment variables are set
if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
  if $darwin; then
    # Bugzilla 54390
    if [ -x '/usr/libexec/java_home' ] ; then
      export JAVA_HOME=`/usr/libexec/java_home`
    # Bugzilla 37284 (reviewed).
    elif [ -d "/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home" ]; then
      export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home"
    fi
  else
    JAVA_PATH=`which java 2>/dev/null`
    if [ "x$JAVA_PATH" != "x" ]; then
      JAVA_PATH=`dirname $JAVA_PATH 2>/dev/null`
      JRE_HOME=`dirname $JAVA_PATH 2>/dev/null`
    fi
    if [ "x$JRE_HOME" = "x" ]; then
      # XXX: Should we try other locations?
      if [ -x /usr/bin/java ]; then
        JRE_HOME=/usr
      fi
    fi
  fi
  if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
    echo "Neither the JAVA_HOME nor the JRE_HOME environment variable is defined"
    echo "At least one of these environment variable is needed to run this program"
    exit 1
  fi
fi
if [ -z "$JAVA_HOME" -a "$1" = "debug" ]; then
  echo "JAVA_HOME should point to a JDK in order to run in debug mode."
  exit 1
fi
if [ -z "$JRE_HOME" ]; then
  JRE_HOME="$JAVA_HOME"
fi

# If we're running under jdb, we need a full jdk.
if [ "$1" = "debug" ] ; then
  if [ "$os400" = "true" ]; then
    if [ ! -x "$JAVA_HOME"/bin/java -o ! -x "$JAVA_HOME"/bin/javac ]; then
      echo "The JAVA_HOME environment variable is not defined correctly"
      echo "This environment variable is needed to run this program"
      echo "NB: JAVA_HOME should point to a JDK not a JRE"
      exit 1
    fi
  else
    if [ ! -x "$JAVA_HOME"/bin/java -o ! -x "$JAVA_HOME"/bin/jdb -o ! -x "$JAVA_HOME"/bin/javac ]; then
      echo "The JAVA_HOME environment variable is not defined correctly"
      echo "This environment variable is needed to run this program"
      echo "NB: JAVA_HOME should point to a JDK not a JRE"
      exit 1
    fi
  fi
fi

# Don't override the endorsed dir if the user has set it previously
if [ -z "$JAVA_ENDORSED_DIRS" ]; then
  # Set the default -Djava.endorsed.dirs argument
  JAVA_ENDORSED_DIRS="$OPENCRON_HOME"/endorsed
fi

if [ -z "$JAVACMD" ] ; then
  if [ -n "$JAVA_HOME"  ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
      # IBM's JDK on AIX uses strange locations for the executables
      JAVACMD="$JAVA_HOME/jre/sh/java"
    else
      JAVACMD="$JAVA_HOME/bin/java"
    fi
  else
    JAVACMD="`which java`"
  fi
fi

#check java exists.
$JAVACMD >/dev/null 2>&1

if [ $? -ne 1 ];then
  echo_r "ERROR: java is not install,please install java first!"
  exit 1;
fi

#check openjdk
if [ "`$JAVACMD -version 2>&1 | head -1|grep "openjdk"|wc -l`"x == "1"x ]; then
  echo_r "ERROR: please uninstall OpenJDK and install JDK 1.7+ first"
  exit 1;
fi

echo_w "build opencron Starting...";

if [ ! -f "${WORKDIR}/.mvnw" ];then
    echo_r "ERROR: ${WORKDIR}/.mvnw is not exists,This file is needed to run this program!"
    exit 1;
fi

${WORKDIR}/.mvnw clean install -Dmaven.test.skip=true;

retval=$?

if [ ${retval} -eq 0 ] ; then
    [ ! -d "${DIST_HOME}" ] && mkdir ${DIST_HOME} || rm -rf  ${DIST_HOME}/* ;
    cp ${OPENCRON_AGENT} ${DIST_HOME}
    cp ${OPENCRON_SERVER} ${DIST_HOME}
    printf "[${BLUE_COLOR}opencron${RES}] ${WHITE_COLOR}build opencron @Version ${OPENCRON_VERSION} successfully! please goto${RES} ${GREEN_COLOR}${DIST_HOME}${RES}\n"
    exit 0
else
    echo_r "build opencron failed! please try again "
    exit 1
fi
