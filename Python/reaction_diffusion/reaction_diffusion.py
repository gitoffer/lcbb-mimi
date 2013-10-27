#!/usr/bin/python

import numpy as np
import scipy.sparse as sparse
import pylab as pl

import matplotlib.pyplot as plt

# import time

# --- Model paramters ---
#		Initial conditions
#		Diffusion constant
#		Reaction coefficient
# --- Simulation parameters ---
# 	Lattice size
#		Temporal discretization
#		Simulation size

def normalize(A):
	A = A / sum(A)
	return A

def spatialLaplacian( A, dx2, dy2):
	lapA = A
	
	dxx = ( A[2: ,1:-1] - 2 * A[1:-1,1:-1] + A[ :-2,1:-1] ) / dx2
	dyy = ( A[1:-1,2: ] - 2 * A[1:-1,1:-1] + A[1:-1, :-2] ) / dy2

	lapA[1:-1,1:-1] = dxx + dyy

	return lapA

# Diffusion constant
D = 0.5
# Reaction rate (degredation)
k = 0.001

# Lattice size(s) and stepsize(s)
dx = 0.5
dy = 0.5
Nx = 50
Ny = 50

# Determine temporal stepsize by stability criterion
dx2 = dx**2
dy2 = dy**2
dt = (dx2 * dy2) / ( 2 * 0.02 * (dx2 + dy2) )
dt = 0.001

# Number of steps
numTimeStep = 1000

# Initial Conditions
u = np.random.rand( Nx,Ny )
v = np.random.rand( Nx,Ny )
ui = normalize( np.copy(u) )
vi = normalize( np.copy(v) )
v = np.zeros( (Nx,Ny) )

histU = []
histV = []
for i in range( numTimeStep ):

	histU.append( np.copy(u) )
	histV.append( np.copy(v) )
	
	u = ui + ( 5*spatialLaplacian(u,dx2,dy2) \
					+ 3 - (5+1) * u ) * dt
	v = vi + ( 12*spatialLaplacian(v,dx2,dy2) \
					+ 5 * u - u**2 ) * dt

	ui = np.copy(u)
	vi = np.copy(v)

tfinish = time.time()

print "Time elapsed: ", tfinish-tstart, " (sec)"

