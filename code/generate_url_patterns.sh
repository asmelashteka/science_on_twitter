#!/bin/bash

if [[ $# -eq 6 ]]
then
   user_info=$1
   conf_info=$2
   negative_info=$3
   out_domain=$4
   out_suffix=$5
   top_k=$6
else
   echo "usage: generate_url_patterns.sh <user info> <conf info> <negative info> <domain output> <suffix output>"
   exit 1
fi

cut -f6 $user_info | sed '/^$/d' |code/parse_urls.py > __user.urls.tld
cut -f6 $conf_info | sed '/^$/d' |code/parse_urls.py > __conf.urls.tld
cut -f6 $negative_info | sed '/^$/d' |code/parse_urls.py > __negative.urls.tld

cut -f3 __user.urls.tld __conf.urls.tld __negative.urls.tld |tr 'A-Z' 'a-z' | sort | uniq -c | sort -nr |head -n $top_k |sed 's/ *//' | sed 's/ /\t/' |cut -f2 > $out_domain
cut -f4 __user.urls.tld __conf.urls.tld __negative.urls.tld |tr 'A-Z' 'a-z' | sort | uniq -c | sort -nr |head -n $top_k |sed 's/ *//' | sed 's/ /\t/' |cut -f2 > $out_suffix

echo "Done."
rm __*
