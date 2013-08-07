#! /usr/bin/env python

import sys
from numpy import *
from sklearn import svm
import pickle

def main():

	if len(sys.argv) == 3:
		training_data_file = sys.argv[1]
		model_output_file = sys.argv[2]
	else:
		print "usage: ./modeling.py <training_data_file> <model_output_file>"

	# Read data to numpy array
	training_data = genfromtxt(training_data_file, delimiter="\t")
	rows, cols = training_data.shape

	# Build svm classifier
	author_clf = svm.SVC(gamma = 0.001, C=100.)
	author_clf.fit(training_data[:, 2:cols-1], training_data[:,cols-1])

	# Test classifier
		
	# Save model
	s = pickle.dumps(author_clf)
	with open(model_output_file, "w") as f:
		f.write(s)
	
if __name__ == '__main__':
	main()
