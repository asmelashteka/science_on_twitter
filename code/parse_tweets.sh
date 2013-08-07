#!/bin/bash

# Helper script to parse tweet downloads by dimentions of interest
# such as organic tweets, retweets, hashtags, mentions, urls etc.

# Extracting content from conference tweets
cat ../conferences/conf.tweets |  awk -F"\t" '!seen[$1$2]++{print $0}' | ~/code/parse_tweets.py conferences/conf.tweets conferences/conf.retweets conferences/conf.hashtags conferences/conf.mentions conferences/conf.urls

# Extracting content from user tweets
cat ../users/user.tweets | ~/code/parse_tweets.py users/user.tweets users/user.retweets users/user.hashtags users/user.mentions users/user.urls

# Extracting content from randomly sampled users tweets
cat ../non_researchers/random.tweets | ~/code/parse_tweets.py random/rand.tweets random/rand.retweets random/rand.hashtags random/rand.mentions random/rand.urls

# Subset content by users from dblp
cat ../users/user.tweets | code/subset_bigfile.py dblp/user.ids > dblp/tweets.dblp_users
cat dblp/tweets.dblp_users | ~/code/parse_tweets.py dblp/user.tweets dblp/user.retweets dblp/user.hashtags dblp/user.mentions dblp/user.urls


echo "Done!"
