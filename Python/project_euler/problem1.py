#!/usr/bin/python
"""
Multiples of 3 and 5

If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.

Find the sum of all the multiples of 3 or 5 below 1000.

#

Code solution: use two generators to generate a list of multiples of 3 and multiples of 5, respectively. Then convert to set structure to get rid of over-counting.

xies@mit.edu August 2013

"""

def next_multiple_of_3(x):
	# use a generator to get next multiple of 3
	while True:
		if x % 3 == 0:
			yield x
		x += 1
	
def next_multiple_of_5(x):
	# generator to get multiples of 5
	while True:
		if x % 5 == 0:
			yield x
		x += 1

def problem1():
	#get a list of
	total = []

	for mult3 in next_multiple_of_3(1):
		if mult3 < 1000:
			total.append( mult3 )
		else:
			break

	for mult5 in next_multiple_of_5(1):
		if mult5 < 1000:
			total.append( mult5 )
		else:
			break
	
	# convert to set to get unique values
	print total
	total = set(total)
	print total
	total = sum(total)
	print total
	return

if __name__ == '__main__':
	problem1()

