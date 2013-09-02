#!/usr/bin/python


def euler_algorithm(a,b):
	m = max([a,b])
	n = min([a,b])
	if m**2-n**2 < 0:
		print m,n
	return [m**2-n**2, 2*m*n, m**2+n**2]

def problem9():
	for m in range(1,100):
		for n in range(1,100):
			[a,b,c] = euler_algorithm(m,n)
			if a**2+b**2 != c**2:
				print "NOT TRIPLE"
			if a+b+c == 1000:
				print a*b*c
				return

if __name__ == "__main__":
	problem9()
