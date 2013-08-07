#! /usr/bin/env python
# Script to compute co-occurence of hashtags/mentions etc.
# Example usage:
# cat user.hashtags | python compute_cooccurrence.py seed.hashtags > hashtag.cooccurrence
import sys

def main():
	if len(sys.argv) == 2:
		# Read file with seed file
		seed_terms_file = sys.argv[1]
	else:
		print "usage: cat <big file> | python compute_cooccurrence.py <seed file>"
		return 
	# Open file containing seed hashtags/mentions, and store terms in hash
	seeds = {}
	with open(seed_terms_file, "r") as f:
		for line in f:
			seeds[line.strip()]=''
	original_dataset = {}
	seed_by_tweetIds = {}
	# Read big file from standard input
	for line in sys.stdin:
		try:
			# Parse input entries
			key, term = line.strip().split("\t")
			
			# Keep input data indexed by key
			if key not in original_dataset:
				original_dataset[key] = [term]
			else:
				original_dataset[key].append(term)

			# Keep track of keys that contain seed
			if term in seeds:
				if key not in seed_by_tweetIds:
					seed_by_tweetIds[key] = [term]
				else:
					seed_by_tweetIds[key].append(term)
		except:
			sys.stderr.write( "Wrong fields: " + line )
			continue

	# Write result to standard output
	for key, seeds in seed_by_tweetIds.iteritems():
		for seed in seeds:
			for item in original_dataset[key]:
				if item != seed:
					sys.stdout.write(key + "\t" + seed + "\t" + item + "\n")
	# Gracefull finish
	sys.stderr.write("Done!\n")

if __name__ == '__main__':
	main()
