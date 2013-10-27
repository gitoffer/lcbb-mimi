#!/user/bin/python
"""
The prime factors of 13195 are 5, 7, 13 and 29.

What is the largest prime factor of the number 600851475143?

Solution:
	Use an iterator to generate all factors (possibly non-prime) of a number and check for primeness

xies@mit.edu August 2013

"""
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

def factorize(x):
	return set(reduce(list.__add__,
		([i, x//i] for i in range(1, int(math.sqrt(x)) + 1) if x % i == 0)))

def problem3():
	largest = 0
	for factor in factorize(600851475143):
		if is_prime(factor):
			largest = max(factor,largest)
	
	print largest

if __name__ == '__main__':
	problem3()
