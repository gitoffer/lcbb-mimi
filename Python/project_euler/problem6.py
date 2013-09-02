#!/usr/bin/python

from math import floor

def square_consecutive_sum(n):
	left_over = n % 2
	num_pairs = floor(n/2)
	if left_over > 0:
		return (num_pairs*(1+n-1) + n)**2
	else:
		return (num_pairs*(n+1))**2

def consecutive_square_sum(n):
	return n*(n+1)*(2*n+1)/6

def problem6():
	print square_consecutive_sum(100) - consecutive_square_sum(100)
