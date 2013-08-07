#! /usr/bin/env python
import sys
import tldextract

def encode(fragment, frequent_pattern):
   """
   If fragment is not in frequent_pattern encode as 'other'
   """
   fragment = fragment.lower()
   if fragment not in frequent_pattern:
      return "other"
   return fragment

def url_features(url, frequent_domain, frequent_suffix):
   """ Accepts a String url, and a list of key words
       Outputs url features"""
   # contains url?, url contains pattern?, tld features
   url = url.strip()
   if url == '' or 'http' not in url:
      return ["0", "NA", "NA", "NA", "NA"]
   else:
      # profile contains url
      result = ["1"]
      # check tilda ~
      if "~" in url:
         result.append("1" )
      else:
         result.append("0")
      # Check for .edu
      if ".edu" in url:
         result.append("1")
      else:
         result.append("0")
      # Check tld features
      # parse url into subdomain,  domain, suffix
      url_parts = tldextract.extract(url) 
      domain_part, suffix_part = url_parts[1:]
      domain_part = encode(domain_part, frequent_domain)
      suffix_part = encode(suffix_part, frequent_suffix)
      url_parts = [domain_part, suffix_part]
      result.extend(url_parts)

   return result

def description_features(description, description_patterns):
   """ Accepts String user description, list of key words
       Outputs description features"""
   # Contains bio?, bio contains pattern?
   description = description.strip()
   if description == '':
      return ["0", "NA"]
   else:
      for pattern in description_patterns:
         if pattern in description:
            return ["1", "1"]
      return ["1", "0"]

def screen_name_features(screen_name):
   """ Accepts String screen name of twitter accounts
       And returns a list of features. """
   # 
   
def check_location(location):
   """ Accepts String location info
   returns whether or not it exists"""
   location = location.strip()
   if location == '':
      return "0"
   return "1"

def main():
   # Command line arguments
   if len(sys.argv) == 5:
      user_info_file = sys.argv[1]
      description_keyterms_file = sys.argv[2]
      url_domain_file = sys.argv[3]
      url_suffix_file = sys.argv[4]
   else:
      sys.stderr.write( "usage: ./profile_features.py <user info> <description terms> <url domain terms> <url suffix file>\n" )
      return

   frequent_domain = set([])
   frequent_suffix = set([])
   description_patterns = set([])

   # Keep description patterns for lookup
   with open(description_keyterms_file, "r") as f:
      for line in f:
         keyterm = line.strip()
         if not keyterm.startswith( "#" ):
            description_patterns.add( keyterm )

   # Keep url patterns for lookup
   with open(url_domain_file, "r") as f:
      for line in f:
         keyterm = line.strip()
         if not keyterm.startswith( "#" ):
            frequent_domain.add( keyterm )

   with open(url_suffix_file, "r") as f:
      for line in f:
         keyterm = line.strip()
         if not keyterm.startswith( "#" ):
            frequent_suffix.add( keyterm )

   # Header info.
   sys.stdout.write( "Id" + "\tnof_followers" + "\tnof_friends" + "\tnof_tweets" + "\thas_url" + "\turl_has_tild" + "\turl_has_dot_edu" + "\turl_part_domain" + "\turl_part_suffix" + "\thas_description" + "\tdescription_has_pattern" + "\n" )
   
   with open(user_info_file, "r") as f:
      for line in f:
         try:
            userId, user_description, nof_followers, nof_friends, nof_tweets, user_url = line.split("\t")
         except:
            sys.stderr.write("Wrong formatting: " + line)
            continue

         # Generate features
         location_exists = check_location(location_info)
         friend_follower_ratio = nof_friends / (nof_followers + 0.01)
         screen_name_features(screen_name)
         global_signals = [nof_followers, nof_friends, nof_tweets]
         description_signals = description_features(user_description, description_patterns)
         url_signals = url_features(user_url, frequent_domain, frequent_suffix)
         
         # Print feature vector to standard output
         sys.stdout.write( userId + "\t" + "\t".join(global_signals) + "\t" + "\t".join(description_signals) + "\t" + "\t".join(url_signals) + "\n")
   
if __name__ == '__main__':
   main()
