#!/usr/bin/python
# Gets rid of the first two lines of GEAS output, as well as the
# third column empty column for easy MATLAB import.
# xies@mit.edu

import sys, getopt, os.path, os, re

def main(argv):
	print '\n\n' # Display border

	# Parse arguments
	input_name = ''
	output_name = ''

	# Construct inputs flags via getopt
	try:
		opts, args = getopt.getopt(argv,"hi:o:",["help","input=","output="])
	except getopt.GetoptError as err:
		# Unrecognized options
		usage()
		sys.exit(2)

	# Examine flags and arguments
	for o, a in opts:
		if o in ('-h','--help'): # help flag
			usage()	
			sys.exit()
		elif o in ('-i','--input'): # input flag
			input_name = a
			input_basename = os.path.basename(input_name)
			input_basename = os.path.splitext(input_basename)[0]

			# Create output directory and specify output filename:
			input_dir = os.path.dirname(input_name)
			# Search for matches to 'method_c??_distance'
			match = re.search(r'c[\d]+_[\w]+',input_name)
			try: new_basedir = ''.join(['/',match.group(),'/'])
			except AttributeError:
				print 'Invalid input filename. Must be in the format ''method_c??_distance''.'
			output_dir = ''.join([input_dir,new_basedir])
			
			# Make new directory given input
			try: os.mkdir(output_dir)
			except OSError as err:
				# Directory already exists... do nothing
				print 'Directory ', new_basedir, ' already exists.'
			output_name = ''.join([input_dir,new_basedir,input_basename,'.txt'])

	# Opens the input filestream
	try: input_stream = open(input_name,'r')
	except IOError:
		print "Error opening ", input_name
		usage()
		sys.exit()
	
	print 'Processing ', input_name
	
# Reads each line into an array, gets rid of 3rd element
	new_lines = []
	for line in input_stream:
		this_array = line.split('\t')
		this_array.pop(2)
		# Join the tab-separated elements into a single tab-separated string
		new_lines.append('\t'.join(this_array));

	# Gets rid of first 2 lines (headers)
	new_lines.pop(0)
	new_lines.pop(0)

	# Make the appropriate directory

	# Write to output file
	try: output_stream = open(output_name,'w')
	except IOError:
		print "Error opening ", output_name
		sys.exit()
	for line in new_lines:
		output_stream.write(line)

	print "Written new file to: ", output_name


# Help statement
def usage():
	print "Usage: process_gedas_txt.py -i <INPUT>"

if __name__ == '__main__':
	main(sys.argv[1:])

	
