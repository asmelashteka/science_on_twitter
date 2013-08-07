#!/bin/bash

# Prepare user info downloads for feature construction
# replace urls by Unshortened urls

# Unshorten urls in bio
#------------------------------------------------------

# users
# cut -f1,14 ../users/user.info |grep -v $'\t\s*$' |grep -i '^[1-9]' | grep $'[a-z]' |grep 'http' |cut -f2 | code/unshortenURL.py > __url__unshortenedUrl
# join -t$'\t' -1 2 -2 1 -o '1.1 1.2 2.2' <(cut -f1,14 ../users/user.info | sort -t$'\t' -k2,2) <(sort -t$'\t' -k1,1 __url__unshortenedUrl) > users/user.urls-in-bio 

# confs
# cut -f1,14 ../conferences/conf.info |grep -v $'\t\s*$' |grep -i '^[1-9]' | grep $'[a-z]' |grep 'http' |cut -f2 | code/unshortenURL.py > __url__unshortenedUrl
# join -t$'\t' -1 2 -2 1 -o '1.1 1.2 2.2' <(cut -f1,14 ../conferences/conf.info | sort -t$'\t' -k2,2) <(sort -t$'\t' -k1,1 __url__unshortenedUrl) > conferences/conf.urls-in-bio 

# random sample
# cut -f1,14 ../non_researchers/random.info |grep -v $'\t\s*$' |grep -i '^[1-9]' | grep $'[a-z]' |grep 'http' |cut -f2 | code/unshortenURL.py > __url__unshortenedUrl
# join -t$'\t' -1 2 -2 1 -o '1.1 1.2 2.2' <(cut -f1,14 ../non_researchers/random.info | sort -t$'\t' -k2,2) <(sort -t$'\t' -k1,1 __url__unshortenedUrl) > random/random.urls-in-bio


# Basic counts and  extended urls in bio
#------------------------------------------------------

# users
cat users/user.urls-in-bio | awk -F"\t" 'OFS="\t" {gsub("^\\/", $2, $3); print $0}' | cut -f1,3 | sort -t$'\t' -k1,1 > __Id__unshortenedUrl
cut -f1,3,4,5,6,7,8 ../users/user.info | grep '^[1-9]' | sort -t$'\t' -k1,1 | join -t$'\t' -1 1 -2 1 -a1 -e "" -o '1.1 1.2 1.3 1.4 1.5 1.6 1.7 2.2' - __Id__unshortenedUrl > users/user.info

# users in DBLP
cat users/user.info | ./code/filter_bigfile.py dblp/user.ids > dblp/user.info

# confs
cat conferences/conf.urls-in-bio | awk -F"\t" 'OFS="\t" {gsub("^\\/", $2, $3); print $0}' | cut -f1,3 | sort -t$'\t' -k1,1 > __Id__unshortenedUrl
cut -f1,3,4,5,6,7,8 ../conferences/conf.info | grep '^[1-9]' | sort -t$'\t' -k1,1 | join -t$'\t' -1 1 -2 1 -a1 -e "" -o '1.1 1.2 1.3 1.4 1.5 1.6 1.7 2.2' - __Id__unshortenedUrl > conferences/conf.info

# negative sample users
cat random/rand.urls-in-bio | awk -F"\t" 'OFS="\t" {gsub("^\\/", $2, $3); print $0}' | cut -f1,3 | sort -t$'\t' -k1,1 > __Id__unshortenedUrl
cut -f1,3,4,5,6,7,8 ../non_researchers/negative.info |grep '^[1-9]' | sort -t$'\t' -k1,1 | join -t$'\t' -1 1 -2 1 -a1 -e "" -o '1.1 1.2 1.3 1.4 1.5 1.6 1.7 2.2' - __Id__unshortenedUrl > random/negative.info

# big random sample
cat random/random.urls-in-bio | awk -F"\t" 'OFS="\t" {gsub("^\\/", $2, $3); print $0}' | cut -f1,3 | sort -t$'\t' -k1,1 > __Id__unshortenedUrl
cut -f1,3,4,5,6,7,8 ../non_researchers/random.info | grep '^[1-9]' | sort -t$'\t' -k1,1 | join -t$'\t' -1 1 -2 1 -a1 -e "" -o '1.1 1.2 1.3 1.4 1.5 1.6 1.7 2.2' - __Id__unshortenedUrl > random/rand.info 

rm __*
echo "Done!"

