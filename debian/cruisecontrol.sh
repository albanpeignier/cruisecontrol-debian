#!/bin/sh

################################################################################
# CruiseControl, a Continuous Integration Toolkit
# Copyright (c) 2001, ThoughtWorks, Inc.
# 651 W Washington Ave. Suite 500
# Chicago, IL 60661 USA
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     + Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     + Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#
#     + Neither the name of ThoughtWorks, Inc., CruiseControl, nor the
#       names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior
#       written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
################################################################################

basename=`basename $0`

function usage() {
    cat <<EOF

Usage:

Starts a continuous integration loop

$basename [options]
where options are:

   -jmxport number				where number is the port of the Controller web site
   -webport number			where number is the port for the Reporting website
   -configfile file   where file is the configuration file

Debian options

   -jetty							starts the jetty engine to make the web interface available
   -basedir dir				where dir is the base directory to execute CruiseControl
   -log url						where url is the log4j configuration url
   -daemon							to send the started CruiseControl process in background
EOF
    exit 1
}

# The root of the CruiseControl directory.  The key requirement is that this is the parent
# directory of CruiseControl's lib and dist directories.
if [ -z "$CRUISE_DIR" ]; then
    CRUISE_DIR=/usr/share/cruisecontrol
fi

LIBDIR=$CRUISE_DIR/lib
DISTDIR=$CRUISE_DIR/dist

temp=`getopt -o "" -a --long "port:,webport:,rmiport:,webport:,configfile:,log:,classpath:,basedir:,daemon,jetty" -n $basename  -- "$@"`
if [ $? != 0 ]; then
    usage
fi

eval set -- "$temp"

while [ "$1" != "--" ]; do
    case "$1" in
	--configfile)
	    configfile=$2
	    shift 2
	;;
	--jmxport|--port)
	    port=$2
	    shift 2
	;;
	--classpath)
	    CRUISE_PATH="$CRUISE_PATH:$2"
	    shift 2
	;;
	--log)
	    log=$2
	    shift 2
	;;
	--basedir)
	    basedir=$2
	    shift 2
	;;
  --daemon)
	    daemon=true
	    shift 1
	;;
  --jetty)
	    jetty=true
	    shift 1
	;;
  --webport)
	    webport=$2
	    shift 2
	;;
  --rmiport)
	    rmiport=$2
	    shift 2
	;;
	*)
            usage
	;;
    esac
done

# create the CruiseControl arguments (configfile, port)
[ -z "$configfile" ] && usage
CRUISE_OPTS="-configfile $configfile"
[ -n "$port" ] && CRUISE_OPTS="$CRUISE_OPTS -jmxport $port"

# create the CruiseControl classpath
CRUISE_PATH="$CRUISE_PATH:.:$DISTDIR/cruisecontrol.jar:$DISTDIR/cruisecontrol-launcher.jar"
[ -n "$JAVA_HOME" ] && CRUISE_PATH="$CRUISE_PATH:$JAVA_HOME/lib/tools.jar"

for jar in $LIBDIR/*.jar; do
    CRUISE_PATH="$CRUISE_PATH:$jar"
done

# if available, use the xalan and oro jar files
for jar in /usr/share/java/xalan2.jar /usr/share/java/oro.jar; do
    [ -f $jar ] && CRUISE_PATH="$CRUISE_PATH:$jar"
done

# choose the JVM executable
JAVA_CMD="java"
[ -n "$JAVA_HOME" ] && JAVA_CMD="$JAVA_HOME/bin/java"

# create the log4j configuration property
[ -n "$log" ] && JAVA_OPTIONS="$JAVA_OPTIONS -Dlog4j.configuration=$log"

[ -n $rmiport ] && CRUISE_OPTS="$CRUISE_OPTS -rmiport $rmiport"

JAVA_OPTIONS="$JAVA_OPTIONS -Djavax.management.builder.initial=mx4j.server.MX4JMBeanServerBuilder"

# if necessary, change to the base directory
[ -n "$basedir" ] && cd $basedir

CRUISE_MAIN=CruiseControl
if [ -n "$webport" ]; then
	CRUISE_MAIN=CruiseControlWithJetty
  CRUISE_OPTS="$CRUISE_OPTS -cchome /usr/share/cruisecontrol -webport ${webport} -webapppath /usr/share/cruisecontrol/webapps/cruisecontrol -dashboard /usr/share/cruisecontrol/webapps/dashboard"
  JAVA_OPTIONS="$JAVA_OPTIONS -Djetty.logs=/var/log/cruisecontrol -Djetty.port=${webport} -Ddashboard.config=/etc/cruisecontrol/dashboard-config.xml -Djava.awt.headless=true"

	if [ -z "$JAVA_HOME" ]; then
		JDK_DIRS=`ls -d /usr/lib/j2sdk* 2> /dev/null || true`

		for jdir in $JDK_DIRS; do
	    if [ -d "$jdir" -a -f "$jdir/lib/tools.jar" -a -z "${JAVA_HOME}" ]; then
        JAVA_HOME="$jdir"
	    fi
		done
		echo "use $JAVA_HOME as JAVA_HOME";
		export JAVA_HOME
	fi

	if [ ! -f "$JAVA_HOME/lib/tools.jar" ]; then
		echo "Jetty needs to compile jsps, you must specify a valid JDK via JAVA_HOME";
		exit 1;
	fi

	CRUISE_PATH="$CRUISE_PATH:$JAVA_HOME/lib/tools.jar"
fi

EXEC="$JAVA_CMD $JAVA_OPTIONS -cp $CRUISE_PATH $CRUISE_MAIN $CRUISE_OPTS"

if [ -n "$daemon" ]; then
    default_outputfile="/var/log/cruisecontrol/cruisecontrol.out"
    if [ -z "$CRUISE_OUTPUTFILE" ]; then
        CRUISE_OUTPUTFILE=$default_outputfile
    fi

    if [ ! -w "$CRUISE_OUTPUTFILE" ]; then
        echo "$CRUISE_OUTPUTFILE isn't writable, output redirected to /dev/null"
        CRUISE_OUTPUTFILE="/dev/null"
    fi

    echo $EXEC >> "$CRUISE_OUTPUTFILE"

    $EXEC 2>&1 >> "$CRUISE_OUTPUTFILE" &

    if [ -z "$CRUISE_PIDFILE" ]; then
        CRUISE_PIDFILE="/var/run/cruisecontrol.pid"
    fi

    if [ -w "$CRUISE_PIDFILE" ]; then
      echo $! > "$CRUISE_PIDFILE"
    else
      echo "$CRUISE_PIDFILE isn't writable, the JVM pid is $!"
    fi
else
    exec $EXEC
fi
