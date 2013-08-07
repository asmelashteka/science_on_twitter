#!/bin/bash

# Script to generate discriminating features from user profile

# Rational: We could harnese good signal from profile info
# One way to tell whether a twitter account belongs to a researcher or not is to see if 
# the user uses terms like: i'm phd, researcher, scientist etc.

# Accept command line arguments
if [[ $# -eq 3 ]]
then
   user_info=$1
   conf_info=$2
   random_info=$3
else
   echo "usage: ./generate_profile_features.sh <dblp info> <conf info> <random info>"
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


# Discriminating tokens (uni-grams)
#--------------------------------------------------
# Generate tokens from potential researchers - positive
unigram $user_info 5 > __unigram__#positive

# Generate tokens from conferences and random users - negative
unigram $conf_info 3 > __unigram__#conf
unigram $random_info 5 > __unigram__#rand
cat __unigram__#rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.01*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __unigram__#rand_top1

cat __unigram__#rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.05*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __unigram__#rand_top5

cat __unigram__#rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.10*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __unigram__#rand_top10


#################################
# Trying out different thresholds
mkdir -p output_preprocessing

join -t$'\t' -a1 -e "NA" -1 1 -2 1 -o'0 1.2 2.2' __unigram__#positive __unigram__#rand_top1 | join -t$'\t' -a1 -e "NA" -1 1 -2 1 - __unigram__#conf -o '1.1 1.2 1.3 2.2' | sort -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.10*NR; for(i=1; i<= threshold; i++) print a[i]}' | grep -v '^NA' |  grep  $'NA\tNA' > output_preprocessing/unigram.features_top1

join -t$'\t' -a1 -e "NA" -1 1 -2 1 -o'0 1.2 2.2' __unigram__#positive __unigram__#rand_top5 | join -t$'\t' -a1 -e "NA" -1 1 -2 1 - __unigram__#conf -o '1.1 1.2 1.3 2.2' | sort -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.10*NR; for(i=1; i<= threshold; i++) print a[i]}' | grep -v '^NA' |  grep  $'NA\tNA' > output_preprocessing/unigram.features_top5

join -t$'\t' -a1 -e "NA" -1 1 -2 1 -o'0 1.2 2.2' __unigram__#positive __unigram__#rand_top10 | join -t$'\t' -a1 -e "NA" -1 1 -2 1 - __unigram__#conf -o '1.1 1.2 1.3 2.2' | sort -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.10*NR; for(i=1; i<= threshold; i++) print a[i]}' | grep -v '^NA' |  grep  $'NA\tNA' > output_preprocessing/unigram.features_top10


## Not used
## Discriminating phrases (bi-grams)
##--------------------------------------------------
### users
#bigram $user_info 5 > __bigram__#positive
#
### confs
#bigram $conf_info 2 > __bigram__#conf
#
### non-researchers
#bigram $random_info 5 | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.01*NR; for(i=1; i <= threshold;i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __bigram__#rand
#
## Generate sorted list of bi-grams in positive and not in negative by frequency
#cat __bigram__#conf __bigram__#rand |sort -t$'\t' -k1,1 -k2,2nr | awk -F"\t" '!seen[$0]++{print $0}' | sort -t$'\t' -k1,1 > __bigram__#negative
#join -t$'\t' -a1 -e "NA" -1 1 -2 1 -o'0 1.2 2.2' __bigram__#positive __bigram__#negative | sort -t$'\t' -k2,2nr |grep 'NA' | awk -F"\t" '{a[NR] = $0}END{threshold=0.1*NR; for(i=1;i<=NR;i++) if (i <= threshold) print a[i]}' | grep -v '^NA' > __bigram.features
#
#cat __bigram.features >> profile.feature.vector 

rm __*
echo "Done!"
