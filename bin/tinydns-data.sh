#!/bin/bash
set -e
#set -x
data_dir=${DYNDNS_DATA:-/etc/djbdns/tinydns-internal/root}
archive_dir=${DYNDNS_ARCHIVE:-/etc/djbdns/tinydns-internal/root/archive}
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
/usr/bin/tinydns-data
