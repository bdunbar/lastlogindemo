#!/usr/bin/env bash
# lastlogin.sh
# prints the last time each user logged in
# to shell?  to the system?


# Housekeeping
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value


# Variables
batsexec=/usr/local/bin/bats
testfile=/home/bdunbar/workspace/ch/lastlogin.bats
    
function init-test () {
  if [ -x "$batsexec" ]; then
    echo "ok 0 $batsexec exists, continue"
  else
    echo " fail 0 $batsexec not found, exit and read the docs"
    exit 1
  fi
}

utest () {
    bats --tap "$testfile"
    retval=$?
}


print_to_log () {
    for U in $(lastlog | grep -v "Never logged in" | grep -v 'Username' | awk '{ print $1 }')
    do
	USR=$(lastlog | grep -v 'Never logged in' | awk '{ print $1,":",$4,$5,$6,$9 }'| grep $U)
	logger "user lastlogin $USR"
    done
}

print_to_tty () {
    for U in $(lastlog | grep -v "Never logged in" | grep -v 'Username' | awk '{ print $1 }')
    do
	USR=$(lastlog | grep -v 'Never logged in' | awk '{ print $1,":",$4,$5,$6,$9 }'| grep $U)
	echo "user lastlogin $USR"
    done
}

usage () {
    echo "Usage: $0 -l or --log for logger // -t or --tty for tty"
}

# Test
init-test
utest


while [ "$1" != "" ]; do
    case $1 in
	-l | --log )
	    shift
	    print_to_log
	    exit
	;;
	-t | --tty )
	    shift
	    print_to_tty
	    exit
	;;
	-h | --help ) usage
	   exit
	;;
	* ) usage
	    exit 0
    esac
    shift
done
