#!/usr/bin/python
"""
A palindromic number reads the same both ways. The largest palindrome made from the product of two 2-digit numbers is 9009 = 91 × 99.

Find the largest palindrome made from the product of two 3-digit numbers.

Solutions:
	Brute-force it.

"""
def is_palindrome(number):
	number = str(number)
	for i in range( int(len(number)/2) ):
		if number[i] != number[ -i-1 ]:
			return False
	return True

def problem4():
	z = [x*y for x in range(100,999) for y in range(100,999) if is_palindrome(x*y)]
	print max(z)


if __name__ == '__main__':
	problem4()

