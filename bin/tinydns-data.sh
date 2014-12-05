#!/bin/bash
here="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
data="$( cd "$here/../data" && pwd )"
set -e
#set -x
data_file_path=${DYNDNS_DATA_FILE_PATH:-/etc/djbdns/tinydns-internal}
data_dir=${DYNDNS_DATA:-$data}
archive_dir=${DYNDNS_ARCHIVE:-$data_dir/archive}
dyn_dir="${data_dir}/DYNDNS"
static_dir="${data_dir}/DATA"
tmpfile=$(mktemp /tmp/DYNDNS-XXXXXX)
trap "rm -f ${tmpfile}" EXIT ERR 
for m in $static_dir $archive_dir $dyn_dir;do
  [ -d $m ] || mkdir -p $m
done
find $static_dir -type f -exec echo '# {}' \; -exec cat {} \; >> $tmpfile
find $dyn_dir -type f -exec echo '# {}' \; -exec cat {} \; >> $tmpfile
cd "$data_dir"
if [ -f data ];then
  cp data "$archive_dir/$(basename $tmpfile)"
fi
awk -F: '/^=/{if(datas[$1]==""){datas[$1]=$0;print}}/^[^=]/{print}' $tmpfile > data
cp data $data_file_path
