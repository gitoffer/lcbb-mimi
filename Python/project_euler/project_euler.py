#!/usr/bin/python

import math

def is_prime(x):
	#test if x is prime by
	if x > 1:
		if x == 2: # 2 is prime
			return True
		if x % 2 == 0:
			return False
		for current in range(3, int(math.sqrt(x) + 1),2):
			if x % current == 0:
				return False
		return True # no divisors
	return False # 1 isn't a prime

def prime_factorize(x):
	# Factorize an interger x into all factors
	z list(set(reduce(list.__add__,
		([i, x//i] for i in range(1, int(math.sqrt(x)) + 1) if x % i == 0))))
	return [x for x in z if is_prime(x)]

def is_palindrome(number):
	number = str(number)
	for i in range( int(len(number)/2) ):
		if number[i] != number[ -i-1 ]:
			return False
	return True

def lcm(a,b):
	

def gcd(a,b):
