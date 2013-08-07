#!/bin/bash

# Script to generate discriminating features from user profile

# Rational: We could harnese good signal from profile info
# One way to discern a researcher from others to look at patterns of their url
# patterns with edu. and ~ are likely to be researchers.

# Accept command line arguments
if [[ $# -eq 3 ]]
then
   user_info=$1
   conf_info=$2
   random_info=$3
else
   echo "usage: ./generate_url_keywords.sh <user info> <conf info> <random info>"
   exit 1
fi

# Function to compute unigram
# signature unigram <input file> <threshold>
function unigram {
if [[ $# -eq 2 ]]
then
   data_set=$1
   threshold=$2
else
   echo "usage: unigram  <data set> <threshold>"
   return 1
fi

cut -f1,2 $data_set | grep -v $'\t\s*$' | awk -F"\t" 'OFS="\t" {gsub(" ", "\n"$1"\t", $2); print $0}' |sed 's/[[:punct:]]*$//g' | tr 'A-Z' 'a-z' | cut -f2 | sed '/^$/d' | sort -S4G | uniq -c | sed 's/ *//; s/ /\t/' | awk -v threshold=$threshold -F"\t" '{if ($1 > threshold) print $2"\t"$1}' | sort -S4G -t$'\t' -k1,1 | cat
}

# Function to compute bigrams
# signature bigram <input file> <threshold>
function bigram {
if [[ $# -eq 2 ]]
then
   data_set=$1
   threshold=$2
else
   echo "usage: bigram  <data set> <threshold>"
   return 1
fi

cut -f1,5 $data_set | grep -v $'\t\s*$' |awk -F"\t" 'OFS="\t" {gsub(" ", "\n"$1"\t", $2); print $0}' |sed 's/[[:punct:]]*$//g' | sed '/^$/d' | tr 'A-Z' 'a-z' > __list.words
tail -n+2 __list.words > __list.nextwords
paste __list.words __list.nextwords |awk -F"\t" '{if ($1 == $3) print $1"\t"$2"\t"$4}' |sort -u |cut -f2,3 |sort | uniq -c | sort -nr | sed 's/ *//; s/ /\t/' | awk -v threshold=$threshold -F"\t" '{if($1 > threshold) print $2" "$3"\t"$1}' | sort -t$'\t' -k1,1 | cat
rm __list.words __list.nextwords
}


#--------------------------------------------------
# Signal from urls in user profile

# First unshorten urls: takes time, code provided only for reproducibility purposes.
# code/unshorten_urls_bio.sh
cut -f6 $user_info | sed '/^$/d' | ./parse_urls.py > __user.urls
cut -f6 $rand_info | sed '/^$/d' | ./parse_urls.py > __rand.urls
cut -f6 $conf_info | sed '/^$/d' | ./parse_urls.py > __conf.urls

cat __user.urls | grep 'edu' | grep -v '~' | awk -F"\t" '{s=$2"."$3"."$4; print $1"\t"s}' |sed 's/http:\/\///g; s/https:\/\///g' | awk -F"\t" '{if ($1 != $2) print $0}' |less
