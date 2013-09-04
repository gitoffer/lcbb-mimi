#!/usr/bin/python

from itertools import chain

def prime_factorize(n):
	result = [1]
	for i in chain([2] ,xrange(3,n+1,2) ):
		s = 0
		while n % i == 0:
			n /= i
			print n
			s += 1
		result.extend([i]*s)
		if n == 1:
			return result

