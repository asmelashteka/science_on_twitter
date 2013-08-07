#!/bin/bash

# Script to filter parsed tweets for counts
# To generate content and network features
###########################################
# CONTENT INFO
###########################################

# user
cat users/user.hashtags |grep '^[1-9]' | awk -F"\t" '!seen[$0]++{print $1"\t"$3}' > input_content/user.hashtags
cut -f1,4 users/user.mentions | grep '^[1-9]' |  awk -F"\t" '!seen[$0]++{print $0}' > input_content/user.mentions
cut -f1,2 users/user.tweets |grep '^[1-9]' |awk '!seen[$0]++{print $0}' > input_content/user.tweets
cut -f1,2 users/user.retweets |grep '^[1-9]' |awk '!seen[$0]++{print $0}' > input_content/conf.retweets
cut -f1,2 users/user.urls | grep '^[1-9]' | awk -F"\t" '!seen[$0]++{print $0}' > input_content/user.urls

# conf

cat conferences/conf.hashtags |grep '^[1-9]' | awk -F"\t" '!seen[$0]++{print $1"\t"$3}' > input_content/conf.hashtags
cut -f1,4 conferences/conf.mentions | grep '^[1-9]' |  awk -F"\t" '!seen[$0]++{print $0}' > input_content/conf.mentions
cut -f1,2 conferences/conf.tweets |grep '^[1-9]' |awk '!seen[$0]++{print $0}' > input_content/conf.tweets
cut -f1,2 conferences/conf.retweets |grep '^[1-9]' |awk '!seen[$0]++{print $0}' > input_content/conf.retweets
cut -f1,2 conferences/conf.urls | grep '^[1-9]' | awk -F"\t" '!seen[$0]++{print $0}' > input_content/conf.urls

# rand

cat random/rand.hashtags  |grep '^[1-9]' | awk -F"\t" '!seen[$0]++{print $1"\t"$3}' > input_content/rand.hashtags
cut -f1,4 random/rand.mentions | grep '^[1-9]' |  awk -F"\t" '!seen[$0]++{print $0}' > input_content/rand.mentions
cut -f1,2 random/rand.tweets  |grep '^[1-9]' |awk '!seen[$0]++{print $0}' > input_content/rand.tweets
cut -f1,2 random/rand.retweets |grep '^[1-9]' |awk '!seen[$0]++{print $0}' > input_content/rand.retweets
cut -f1,2 random/rand.urls |grep '^[1-9]' |awk '!seen[$0]++{print $0}' > input_content/rand.urls

###########################################
# NETWORK INFO
###########################################

# User
#--------------------------------------------------------
cat ../users/user.friends | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/user.network.friends
cat ../users/user.followers  | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/conf.network.followers
cut -f1,3 users/user.mentions | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/user.network.mention
 cut -f1,4 users/user.retweets | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/user.network.retweet

# Confs
#--------------------------------------------------------
cat ../conferences/conf.friends | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/conf.network.friends
cat ../conferences/conf.followers  | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/conf.network.followers
cut -f1,3 conferences/conf.mentions | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/conf.network.mention
 cut -f1,4 conferences/conf.retweets | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/conf.network.retweet

# Rands
#--------------------------------------------------------
cat ../non_researchers/network.friends | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/rand.network.friends
cat ../non_researchers/network.followers | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/rand.network.followers
 cut -f1,3 random/rand.mentions | awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/rand.network.mention
cut -f1,4 random/rand.retweets| awk -F"\t" '!seen[$0]++{print $0}' | grep '^[1-9]' > input_network/rand.network.retweet

echo "Done!"
