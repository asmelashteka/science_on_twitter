#! /usr/bin/env python
# Script to filter network file to a given list of users.

# Example usage:
# cat retweet.network | filter_network.py researcher.ids > filtered.retweet.network
import sys

def main():
   if len(sys.argv) == 2:
      # Read file names for output
      key = int( sys.argv[1])
      control_ids_file = sys.argv[2]
      
   else:
      print "usage: cat retweet.network | filter_network.py <key field> <control ids> > <output file>"
      return

   # Ids to keep filtering users.
   control_ids = set([])
   with open(control_ids_file, "r") as f:
      for line in f:
         user_id = line.strip()
         control_ids.add(user_id)

   # Read network data from standard input
   for line in sys.stdin:
      try:
         parts = line.strip().split("\t")
         id = parts[key -1]
         if id in control_ids and user2 in control_ids:
            print user1 + "\t" + user2
      except:
         sys.stderr.write("Wrong format: " + line)
if __name__ == '__main__':
   main()
