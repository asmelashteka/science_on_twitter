#! /usr/bin/env python
import sys

def exists_match(userId):
	'''
	Input userId
	Output: boolean status checking for membership in control ids
	'''
	start_pos = 0
        end_pos = len(ids_to_count) - 1
        current_pos = (start_pos + end_pos) / 2
        while (abs(end_pos - start_pos) > 1):
                if ( ids_to_count[current_pos] == userId ):
                        return True
                elif (userId < ids_to_count[current_pos] ):
                        end_pos = current_pos
                else:
                        start_pos = current_pos
                current_pos = (start_pos + end_pos) / 2

        return False


def main():
	if len(sys.argv) == 3:
		network_file = sys.argv[1]
		control_ids = sys.argv[2]
		
	else:
		sys.stderr.write( "usage: ./network_features.py <network-file> <control-ids>\n")
		return
	
	# Collect userIds from control_ids file
	global ids_to_count
	ids_to_count = []
	with open(control_ids, "r") as f:
		for line in f:
			ids_to_count.append(line.strip())
	
	# Sort ids to prepare for binary search
	ids_to_count = sorted(ids_to_count)

	# Go through network file counting control_ids
	nof_controlIds_by_userId = {}
	
	with open(network_file, "r") as f:
		for line in f:
			try:
				primary_userId, related_userId = line.strip().split("\t")
			except:
				sys.stderr.write("Wrong formatting: " + line)
			if primary_userId not in nof_controlIds_by_userId:
				nof_controlIds_by_userId[primary_userId] = 0
			if exists_match(related_userId):
				nof_controlIds_by_userId[primary_userId] += 1

	# Print feature vector to standard output
	for userId, networkCount in nof_controlIds_by_userId.iteritems():
		sys.stdout.write( str(userId) + "\t" + str(networkCount) + "\n")
	
if __name__ == '__main__':
	main()
