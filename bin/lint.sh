#!/bin/bash
# set -x
if [ "$1" == "--" ];then
  shift
fi
fname=$1
if [ ! -f "$fname" ];then
  exit
fi
if [ "${fname##*.}" == "erb" ];then
  tmpfile=$(mktemp /tmp/erblint.XXX)
  trap "rm -f $tmpfile" ERR EXIT
  echo "# rubocop:disable Lint/UnderscorePrefixedVariableName" >$tmpfile
  erb -xT - "$fname" >>$tmpfile
  echo "# rubocop:enable Lint/UnderscorePrefixedVariableName" >>$tmpfile
  sh -c "rubocop -l -f clang -D $tmpfile"
  retval=$?
  exit 0
else
  rubocop  -f clang -D $fname
  exit 0
fi

