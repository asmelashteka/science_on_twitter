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

def contains_tilde(url):
   # check if url contains tilde ~
   if '~' in url:
      return True
   return False

def domain_is_academic(domain):
   # Check if domain contains academic terms 'edu' or 'ac'
   if 'edu' in domain or 'ac' in domain:
      return True
   return False

def url_features(url):
   """ Accepts a String url, and a list of key words
       Outputs url features"""
   # null feature vector: url.exits?, url.contains.tilde, domain is academic
   feature_vector = []

   # Check if url exists
   url = url.strip()
   if url == '' or 'http' not in url:
      feature_vector.extend( ["NA", "NA", "NA"] )
      return feature_vector
   else:
      # profile contains url
      feature_vector.append( True )
      # Check if tilde exists in url
      feature_vector.append( contains_tilde(url))
      # Check TLD features: parse url into subdomain,  domain, suffix
      url_parts = tldextract.extract(url) 
      sub_domain, domain_part, suffix_part = url_parts
      #domain_part = encode(domain_part, frequent_domain)
      #suffix_part = encode(suffix_part, frequent_suffix)
      # Check if domain is academic
      feature_vector.append( domain_is_academic( domain_part ) )
      feature_vector = [ str(feature) for feature in feature_vector]

   return feature_vector

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

def contains_numerals(name):
  # Check if name contains numbers
  if any(c.isdigit() for c in name):
     return True
  return False

def exists(entry):
   """ Check if a given entry is the empty string"""
   if entry.strip() != '':
      return True
   return False

def full_name_features(name):
   """ Accepts String name of twitter user
       And returns a list of features. """
   # feature vector: has name? name contains numerals?
   feature_vector = []
   # Has name
   if not exists(name):
      feature_vector.extend(["False", "NA"])
   else:
      # Name exists
      feature_vector.append(True)
      # Check if name contains number
      feature_vector.append( contains_numerals(name))
      feature_vector = [str(feature) for feature in feature_vector]

   return feature_vector
 
def check_location(location):
   """ Accepts String location info
   returns whether or not it exists"""
   if exists(location):
      return True
   return False

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
   sys.stdout.write( "Id" + "\tname_exists" + "\tname_has_number" + "\tlocation_exists" + "\thas_url" + "\turl_has_tilde" + "\turl_has_academic_domain" + "\thas_description" + "\tdescription_has_pattern" + "\tnof_tweets" + "\tnof_followers" + "\tnof_friends" + "\tfriend_follower_ratio" + "\n" )
   
   with open(user_info_file, "r") as f:
      for line in f:
         try:
            userId, full_name, location_info, user_description, nof_followers, nof_friends, nof_tweets, url = line.split("\t")
         except:
            sys.stderr.write("Wrong formatting: " + line)
            continue
         # Generate features
         try:
            friend_follower_ratio = float(nof_friends) / (float(nof_followers) + 0.01)
            friend_follower_ratio = str(round(friend_follower_ratio, 2))
         except:
            sys.stderr.write("WARNING: Can't compute friend follower ratio. SKIPPING: " + line)
            continue
         # More features ...
         name_features = full_name_features(full_name)
         location_exists = str( check_location(location_info) )
         url_signals = url_features(url)
         description_signals = description_features(user_description, description_patterns)
         global_signals = [nof_tweets, nof_followers, nof_friends, friend_follower_ratio]
         
         # Print feature vector to standard output
         sys.stdout.write( userId + "\t" + "\t".join(name_features) + "\t" + location_exists + "\t" + "\t".join(url_signals) + "\t" + "\t".join(description_signals) + "\t" +"\t".join(global_signals) + "\n")
   
if __name__ == '__main__':
   main()
