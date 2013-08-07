#! /usr/bin/env python

# Script to unshorten url
# Example usage: cat input_file | unshorten_url.py > output_file

import sys
import urllib2

def main():
	for line in sys.stdin:
		input_url = line.strip()
		try:
			response = urllib2.urlopen(input_url)
			print input_url + "\t" + response.url
		except:
			print input_url + "\tERROR"

if __name__ == '__main__':
	main()
