#!/bin/sh

version=`basename $0 | sed 's/ant_j2se//'`
if [ -n "$version" ]; then
    JAVA_HOME="/usr/lib/j2se/$version" 
    if [ ! -d "/usr/lib/j2se/$version" ]; then
        echo "Can't find the JAVA_HOME $JAVA_HOME" >&2
        exit 1
    fi
    export JAVA_HOME
fi

exec /usr/bin/ant $@

