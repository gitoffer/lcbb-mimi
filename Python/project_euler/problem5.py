#!/usr/bin/python

from fractions import gcd

def problem5():
	facts = set([1])
	for i in range(1,21):
		facts.update(gcd(i))

	return list(facts)
