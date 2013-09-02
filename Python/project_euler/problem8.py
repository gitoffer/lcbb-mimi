#!/usr/bin/python

from operator import mul

def product(x):
	return reduce(mul, x)

def problem8(n):

	numstr = str(n)
	largest = 0

	for i in range(0 , len(numstr) - 4):
		y = [int(a) for a in numstr[i:i+5] ]
		largest = max(largest,product(y))


	print largest
	return
