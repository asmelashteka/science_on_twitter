#!/usr/bin/env python
import os
import sys
import operator

# Compute top k influencial users based on
# retweet, mention, and indegree

def write_result(result, output_file):
	"""
	Result a list of tuples.
	Accept result String - output file name.
	Write result to output file
	"""
	with open(output_file, "w") as f:
		for userid, count in result:
			f.write( str(userid) + "\t" + str(count) + "\n" )

def count_influence(network_file):
	"""
	Takes String name to network file as input
	Count the number of relations to a given id and
	Returns a list of tuples of id and count sorted by count
	"""
	count_by_user = {}
	with open(network_file, "r") as f:
		for line in f:
			try:
				user_id, related_id = line.strip().split("\t")
			except:
				sys.stderr.write("WARNING. SKIPPING ..." + line)
				continue
			if not related_id in count_by_user:
				count_by_user[related_id] = 0
			count_by_user[related_id] += 1

	# Sort influence by count
	sorted_count = sorted(count_by_user.iteritems(), key=operator.itemgetter(1), reverse=True)

	return sorted_count

def main ():
	# Accept command line arguments
	if len(sys.argv) == 5:
		retweet_network = sys.argv[1]
		mention_network = sys.argv[2]
		friend_network = sys.argv[3]
		output_directory = sys.argv[4]
		if output_directory[-1] != "/":
			output_directory = os.getcwd() + "/" + output_directory
		
	else:
		sys.stderr.write("usage: rank.py <retweet network> <mention network> <friend network> <output dir>\n")
		return

	# retweet influence
	influence = count_influence(retweet_network)
	output_file = output_directory + retweet_network.split("/")[-1]
	write_result(influence, output_file)
	
	# Mention influence
	influence = count_influence(mention_network)
	output_file = output_directory + mention_network.split("/")[-1]
	write_result(influence, output_file)
	
	# indegree influence
	influence = count_influence(friend_network)
	output_file = output_directory + friend_network.split("/")[-1]
	write_result(influence, output_file)
	
if __name__ == '__main__':
	main()

