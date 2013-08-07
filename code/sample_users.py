#!/usr/bin/env python

# Script to sample users
import sys
import random

def main():
	if len(sys.argv) == 3:
		# Accept command line arguments
		my_seed = int( sys.argv[1])
		sample_size = int( sys.argv[2] )
	else:
		print "usage: cat <data set> | sample_users.py <seed> <sample size>"
		return
	# Set seed to reproduce result	
	random.seed(my_seed)
	
	data_set = []
	for line in sys.stdin:
		data_set.append(line)
	sys.stderr.write("dataset: " + str( len( data_set )) + ". Sample: " + str(sample_size) + "\n")
	sample = random.sample(data_set, sample_size)
	for line in sample:
		sys.stdout.write(line)

if __name__ == '__main__':
	main()
