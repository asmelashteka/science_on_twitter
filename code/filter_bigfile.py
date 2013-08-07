#! /usr/bin/env python
# Script to filter network file to a given list of users.

# Example usage:
# cat retweet.network | filter_network.py researcher.ids > researcher.retweet.network
import sys

def exists(token):
   """
   Input String to lookup
   Output Boolean
   Checks if there is a match
   """
   start_pos = 0
   end_pos = len(control_ids) - 1
   current_pos = (start_pos + end_pos) / 2
   result = False
   while ((end_pos - start_pos) > 1):
      if ( control_ids[current_pos] == token ):
         result = True
         break
      elif (token < control_ids[current_pos] ):
         end_pos = current_pos
      else:
         start_pos = current_pos
      current_pos = (start_pos + end_pos) / 2
   return result

def main():
   if len(sys.argv) == 2:
      # Read file names for output
      control_ids_file = sys.argv[1]
      flag = None
   elif len(sys.argv) == 3:
      control_ids_file = sys.argv[1]
      flag = sys.argv[2] 
   else:
      print "usage: cat <big file> | filter_network.py <control ids> > <filtered file> <optional flag to invert result> "
      return

   # include control ids in filter?
   include_result = True if flag is None else False

   # Ids to keep/exclude users.
   global control_ids
   control_ids = []
   with open(control_ids_file, "r") as f:
      for line in f:
         key = line.strip()
         control_ids.append( key )
   # Sort control ids
   control_ids = sorted(control_ids)

   # Read network data from standard input.
   for line in sys.stdin:
      try:
         parts = line.strip().split("\t")
         key = parts[0]
      except:
         sys.stderr.write("Wrong format: " + line)
         continue
      if bool( exists(key) ) == bool(include_result):
            sys.stdout.write(line)

if __name__ == '__main__':
   main()
