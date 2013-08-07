#!/usr/bin/env python

import sys
# from publicsuffix import PublicSuffixList
import tldextract

# eg. usage:  cut -f6 users/user.info | sed '/^$/d' |code/parse_urls.py > user.urls.tld
def main():
	#pls = PublicSuffixList()
	for line in sys.stdin:
		url = line.strip()
		try:
			parts = tldextract.extract(url)
			sys.stdout.write( url + "\t" + "\t".join(parts) + "\n")
		except:
			sys.sterr.write("Bad input: " + url )

if __name__ == '__main__':
	main()
