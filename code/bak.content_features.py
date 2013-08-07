#! /usr/bin/env python
import sys

def count_occurrence(items_file, users_file):
	"""
	Input:  items_file String name of file with hashtags/mentions/words to count, 
		users_file String name of file with user data user_hashtags/user_mentions to count.
	Output: Count How many times a user mentions items
	"""
	# feature space, e.g hashtags to count
	items_to_count = []
	# user space, e.g count of hashtag mentions by user
	itemCount_by_user = {}
	# Read items to count
	with open(items_file, 'r') as f:
		for line in f:
			item = line.strip().lower()
			items_to_count.append( item)
	f.close()
	
	# Read user data	
	with open(users_file, 'r') as f:
		for line in f:
			try:
				userId, item = line.strip().split("\t")
				item = item.lower()
			except:
				sys.stderr.write('Wrong formatting: ' + line)
				continue
			# Check if item is in items to count.
			if item in items_to_count:
				if not userId in itemCount_by_user:
					itemCount_by_user[userId] = 0
				itemCount_by_user[userId] += 1
	f.close()

	return itemCount_by_user

def count_lines(users_file, distinct = None):
	"""
	Input: String refering to a file containing user items. e.g user retweets
	Output: dict Count of items by user
	"""
	# Keep item counts by user
	itemCount_by_user = {}
	if distinct == None:
		with open(users_file, "r") as f:
			for line in f:
				try:
					userId, item = line.strip().split("\t")
				except:
					sys.stderr.write('Wrong formatting: ' + line)
					continue
				if not userId in itemCount_by_user:
					itemCount_by_user[userId] = 0
				itemCount_by_user[userId] += 1
	else:
		# Keep distinct user item pairs
		distinct_userItem_pair = {}
		with open(users_file, "r") as f:
			for line in f:
				try:
					userId, item = line.strip().split("\t")
					key = (userId, item)
				except:
					sys.stderr.write('Wrong formatting: ' + line)
					continue
				if not key in distinct_userItem_pair:
					distinct_userItem_pair[key] = userId
		# Count each distinct pair by userId
		for key, userId in distinct_userItem_pair.iteritems():
			if not userId in itemCount_by_user:
				itemCount_by_user[userId] = 0
			itemCount_by_user[userId] += 1
	
	return itemCount_by_user
				
def main():
	if len(sys.argv) == 8:
		users_selftweets = sys.argv[1]
		users_retweets = sys.argv[2]
		users_hashtags = sys.argv[3]
		users_mentions = sys.argv[4]
		users_urls = sys.argv[5]
		top_hashtags_file = sys.argv[6]
		top_mentions_file = sys.argv[7]

	else:
		sys.stderr.write( "usage: ./content_features.py <user selftweets> <user retweets> <user hashtags> <user mentions> <user urls> <top conf hashtags> <top conf mentions>\n" )
		return

	# Perfom counts
	conf_hashtag_count = count_occurrence(top_hashtags_file, users_hashtags)
	mention_count = count_occurrence(top_mentions_file, users_mentions)
	url_count = count_lines(users_urls)
	retweet_count = count_lines(users_retweets)
	selftweet_count = count_lines(users_selftweets)
	overall_hashtag_count = count_lines(users_hashtags)
	distinct_hashtag_count = count_lines(users_hashtags, distinct=True)

	# Compute all userIds, assumption every user has at least one of their own tweet
	userIds = set(selftweet_count.keys()).union( set(retweet_count.keys() ) )

	# Print feature vector to standard output
	sys.stdout.write( "Id\t" + "nof.self.tweets\t" + "nof.retweets\t" + "nof.tweets.with.url\t" + "nof.conf.hashtags\t" + "nof.distinct.hashtags\t" + "nof.overall.hashtags" + "\t" + "nof.conf.mentions" + "\n" )
	for userId in userIds:
		if not userId in conf_hashtag_count:
			nof_conf_hashtags = str( 0 )
		else:
			nof_conf_hashtags = str( conf_hashtag_count[userId] )
		if not userId in overall_hashtag_count:
			nof_overall_hashtags = str( 0 )
		else:
			nof_overall_hashtags = str ( overall_hashtag_count[userId])
		if not userId in distinct_hashtag_count:
			nof_distinct_hashtags = str( 0 )
		else:
			nof_distinct_hashtags = str(distinct_hashtag_count[userId])
		if not userId in mention_count:
			nof_conf_mentions = str ( 0 )
		else:
			nof_conf_mentions = str ( mention_count[userId] )
		if not userId in url_count:
			nof_tweetsWithUrl = str ( 0 )
		else:
			nof_tweetsWithUrl = str ( url_count[userId] )
		if not userId in retweet_count:
			nof_retweets = str( 0 )
		else:
			nof_retweets = str( retweet_count[userId] )
		if not userId in selftweet_count:
			nof_selftweets = str ( 0 )
		else:
			nof_selftweets = str( selftweet_count[userId] )
				
		sys.stdout.write( userId + "\t" + nof_selftweets + "\t" + nof_retweets + "\t" + nof_tweetsWithUrl + "\t" + nof_conf_hashtags + "\t" +  nof_distinct_hashtags + "\t" + nof_overall_hashtags + "\t" + nof_conf_mentions + "\n")
	
if __name__ == '__main__':
	main()
