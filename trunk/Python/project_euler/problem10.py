#!/usr/bin/python
"""
The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

Find the sum of all the primes below two million.

Solution:
	Use a generator (again)... to lazy evaluate.

xies @ mit August 2013
"""

import math

def next_prime(n):
	while True:
		n += 1
		if is_prime(n):
			yield n

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

def problem10(threshold):
	total = 2
	for prime in next_prime(2):
		if prime < threshold:
			total += prime
		else:
			print total
			return

if __name__ == '__main__':
	problem10(2000000)
