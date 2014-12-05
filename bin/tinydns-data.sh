#!/bin/bash
here="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
set -e
#set -x
data_dir=${DYNDNS_DATA:-$here/../data}
archive_dir=${DYNDNS_ARCHIVE:-$data_dir/archive}
dyn_dir="${data_dir}/DYNDNS"
static_dir="${data_dir}/DATA"
tmpfile=$(mktemp /tmp/DYNDNS-XXXXXX)
trap "rm -f ${tmpfile}" EXIT ERR 
find $static_dir -type f -exec echo '# {}' \; -exec cat {} \; >> $tmpfile
find $dyn_dir -type f -exec echo '# {}' \; -exec cat {} \; >> $tmpfile
cd "$data_dir"
if [ -f data ];then
  cp data "$archive_dir/$(basename $tmpfile)"
fi
awk -F: '/^=/{if(datas[$1]==""){datas[$1]=$0;print}}/^[^=]/{print}' $tmpfile > data
tinydns-data
