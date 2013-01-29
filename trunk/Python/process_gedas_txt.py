#!/usr/bin/python
# Gets rid of the first two lines of GEAS output, as well as the
# third column empty column for easy MATLAB import.
# xies@mit.edu

import sys, getopt, io

def main(argv):

	# Parse arguments
	input_name = ''
	output_name = ''
	try:
		opts, args = getopt.getopt(argv,"hi:o:",["help","input=","output="])
	except getopt.GetoptError as err:
		# Unrecognized options
		print str(err)
		usage()
		sys.exit(2)
	for o, a in opts:
		if o in ('-h','--help'):
			usage()	
			sys.exit()
		elif o in ('-i','--input'):
			input_name = a
			print 'Processing ', input_name
		elif o in ('-o','--output'):
			output_name = a

	# Opens the input filestream
	try: input_stream = open(input_name,'r')
	except IOError:
		print "Error opening ", input_name
		usage()
		sys.exit()
	
	# Reads each line into an array, gets rid of 3rd element
	new_lines = []
	for line in input_stream:
		this_array = line.split('\t')
		this_array.pop(2)
		new_lines.append('\t'.join(this_array));

	# Gets rid of first 2 lines
	new_lines.pop(0)
	new_lines.pop(0)

	# Write to output file
	try: output_stream = open(output_name,'w')
	except IOError:
		print "Error opening ", output_name
		sys.exit()
	for line in new_lines:
		output_stream.write(line)

	print "Written new file to: ", output_name

def usage():
	print "Usage: process_gedas_txt.py -i <INPUT> -o <OUTPUT>"

if __name__ == '__main__':
	main(sys.argv[1:])

	
