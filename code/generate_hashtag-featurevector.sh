#!/bin/bash

# Script to generate academically/research related hashtags

# Rational: We could harnese good signal by glancing over hashtag usage
# Researchers/Scientisits tend to use similar hashtags(#www2013, #cikm etc.)

# Accept command line arguments
if [[ $# -eq 5 ]]
then
   user_hashtags=$1
   conf_hashtags=$2
   random_hashtags=$3
   user_tweets=$4
   random_tweets=$5
else
   echo "usage: ./generate_hashtag_features.sh <dblp hashtags> <conf hashtags> <random hashtags> <dblp tweets> <random tweets>"
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

##################################################
# APPROACH ZERO: APPEARS WITH SIMILAR WORDS
##################################################
#---------------------------------------------
# Seed hashtags from conferences, seed-hashtags
cut -f1,3 $conf_hashtags | grep '^[0-9]' | tr 'A-Z' 'a-z' | sort -S5G | uniq -c | sed 's/ *//; s/ /\t/' |sort -t$'\t' -k2,2 -k1,1nr |awk '{if ( seen[$2]++ < 3) print $0}' |cut -f3 > __top3.hashtags

# Terms that appear with seed-hashtags in user hashtags
# tweetIds containing seed hashtags
cut -f2,3 $user_hashtags | tr 'A-Z' 'a-z' | awk -F"\t" '{print $2"\t"$1}' |  code/filter_bigfile.py  seed.hashtags > __seed_hashtags_in_users 2> __log.filter.hashtags
cut -f2 __seed_hashtags_in_users | sort -u  > __user.tweetIds.with.top.conf.hashtags

# for user_tweets="dblp/user.all_tweets"
time cut -f2,3 $user_tweets | code/filter_bigfile.py __user.tweetIds.with.top.conf.hashtags > __tweets.with.top.hashtags 2> __log.filter.tweets

# Compute unigrams from tweets containing top hashtags
unigram __tweets.with.top.hashtags 10  | grep -v '^#' | grep -v '^@' | sort -t$'\t' -k1,1 > __unigram__#withseedhashtag

#----------------------------------------------
# tweets containing hashtags, from random tweets
cut -f2 $random_hashtags | sort -u > __rand.tweetIds.with.hashtags
cut -f2,4 $random_tweets | code/filter_bigfile.py __rand.tweetIds.with.hashtags > __rand.tweets.with.hashtags 2> __log.filter.tweets

# Compute unigrams from random tweets
unigram __rand.tweets.with.hashtags 10 | grep -v '^#' | grep -v '^@' | grep  $'[a-z]\|[0-9]\t' > __unigram__#rand

# Explore different thresholds, to fix stop words from random tweets
cat __unigram__#rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.01*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __unigram__#rand_top1

cat __unigram__#rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.05*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __unigram__#rand_top5

cat __unigram__#rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.10*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __unigram__#rand_top10

# top unigrams that appear with conference hashtags
join -t$'\t' -a1 -e "NA" -1 1 -2 1 -o'0 1.2 2.2' __unigram__#withseedhashtag __unigram__#rand_top1 | sort -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.10*NR; for(i=1; i<= threshold; i++) print a[i]}' | grep -v '^NA' |  grep  $'NA' > __unigrams_top1

join -t$'\t' -a1 -e "NA" -1 1 -2 1 -o'0 1.2 2.2' __unigram__#withseedhashtag __unigram__#rand_top5 | sort -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.05*NR; for(i=1; i<= threshold; i++) print a[i]}' | grep -v '^NA' |  grep  $'NA' > __unigrams_top5

join -t$'\t' -a1 -e "NA" -1 1 -2 1 -o'0 1.2 2.2' __unigram__#withseedhashtag __unigram__#rand_top10 | sort -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.05*NR; for(i=1; i<= threshold; i++) print a[i]}' | grep -v '^NA' |  grep  $'NA' > __unigrams_top10

# determine best threshold, through inspection
cut -f1 __unigrams_top5 | tee > __coocurring.terms output_preprocessing/coocurring.terms

#---------------------------------------------
# Hashtags that appear with co-occuring terms

# tweet Ids containing co-occuring terms
# 50min!
#cut -f2,4 $user_tweets | grep '#' | awk -F"\t" 'OFS="\t" {gsub(" ", "\n"$1"\t", $2); print $0}' |sed 's/[[:punct:]]*$//g' | tr 'A-Z' 'a-z' |  grep -v $'\t\s*$' |grep -v $'\t#' | grep -v $'\t@' | grep -v $'\thttp://' | grep -v $'\thttps://' |awk -F"\t" '{print $2"\t"$1}' | code/filter_bigfile.py __coocurring.terms | cut -f2 | awk -F"\t" '!seen[$0]++{print $0}' > __tweetIds.with.coocurring.terms

time  cut -f2,3 $user_tweets | grep '#' | awk -F"\t" 'OFS="\t" {gsub(" ", "\n"$1"\t", $2); print $0}' |sed 's/[[:punct:]]*$//g' | tr 'A-Z' 'a-z' |  grep -v $'\t\s*$' |grep -v $'\t#' | grep -v $'\t@' | grep -v $'\thttp://' | grep -v $'\thttps://' |awk -F"\t" '{print $2"\t"$1}' | code/filter_bigfile.py output_preprocessing/coocurring.terms | cut -f2 | awk -F"\t" '!seen[$0]++{print $0}' | tee __tweetIds.with.coocurring.terms > output_preprocessing/tweetIds.with.coocurring.terms

# Hashtags that appear in these tweetIds
# 4min.
# unique count by tweets!
time cut -f2,3 $user_hashtags | code/filter_bigfile.py __tweetIds.with.coocurring.terms > __user.potential.hashtags0

# unique count by users!
time awk -F"\t" '{print $2"\t"$1" "$3}' $user_hashtags | code/filter_bigfile.py __tweetIds.with.coocurring.terms | sed 's/ /\t/' |cut -f2,3 > __user.potential.hashtags

# choose either unique counts by user or tweet
cat __user.potential.hashtags0 | tr 'A-Z' 'a-z' | awk -F"\t" '!seen[$0]++{print $0}' | cut -f2 | sort -S5G | uniq -c |sed 's/ *//; s/ /\t/' | awk -F"\t" '{print $2"\t"$1}' | sort -t$'\t' -k1,1 > __user.potential.hashtags.by.frequency0

cat __user.potential.hashtags | tr 'A-Z' 'a-z' | awk -F"\t" '!seen[$0]++{print $0}' | cut -f2 | sort -S5G | uniq -c |sed 's/ *//; s/ /\t/' | awk -F"\t" '{print $2"\t"$1}' | sort -t$'\t' -k1,1 > __user.potential.hashtags.by.frequency

# Hashtags that appear in random users
cut -f1,3 $random_hashtags | tr 'A-Z' 'a-z' | awk -F"\t" '!seen[$0]++{print $2}' | sort -S5G | uniq -c |sed 's/ *//; s/ /\t/' |awk -v threshold=5 -F"\t" '{if ($1 > threshold) print $2"\t"$1}'  > __rand.hashtag__#countbyuser

cat __rand.hashtag__#countbyuser | grep  $'[a-z]\|[0-9]\t' > __hashtag__rand

#cat __hashtag__rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.01*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __hashtag__#rand_top01
#
#cat __hashtag__rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.05*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __hashtag__#rand_top05
#
#cat __hashtag__rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.10*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __hashtag__#rand_top10

cat __hashtag__rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.50*NR; for(i=1; i <= threshold; i++) print a[i]}' | sort -S4G -t$'\t' -k1,1 > __hashtag__#rand_top50

# by frequency
cat __hashtag__rand | sort -S4G -t$'\t' -k2,2nr | awk -F"\t" '{if ($2 >= 5) print $0}' | sort -S4G -t$'\t' -k1,1 > __hashtag__#rand_freq5

# Filtering stop words (random hashtags)
join -t$'\t' -a1 -e "NA" -1 1 -2 1 -o'0 1.2 2.2' __user.potential.hashtags.by.frequency0  __hashtag__#rand_top50 | sort -t$'\t' -k2,2nr | awk -F"\t" '{a[NR] = $0}END{threshold=0.05*NR; for(i=1; i<= threshold; i++) print a[i]}' | grep -v '^NA' |  grep  $'NA' > output_preprocessing/research.related.hashtags

cat __top3.hashtags <(cut -f1 output_preprocessing/research.related.hashtags) |sort -u > output_preprocessing/hashtags.boosted

rm __*

