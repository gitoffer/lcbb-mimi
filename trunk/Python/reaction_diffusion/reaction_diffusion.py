#!/usr/bin/python

import numpy as np
import scipy.sparse as sparse
import pylab as pl

import matplotlib.pyplot as plt

import time

# --- Model paramters ---
#		Initial conditions
#		Diffusion constant
#		Reaction coefficient
# --- Simulation parameters ---
# 	Lattice size
#		Temporal discretization
#		Simulation size


def spatialLaplacian( A, dx2, dy2):
	lapA = A
	
	dxx = ( A[2: ,1:-1] - 2 * A[1:-1,1:-1] + A[ :-2,1:-1] ) / dy2
	dyy = ( A[1:-1,2: ] - 2 * A[1:-1,1:-1] + A[1:-1, :-2] ) / dx2

	lapA[1:-1,1:-1] = dxx + dyy

	return lapA

# Diffusion constant
D = 0.5
# Reaction rate (degredation)
k = 0

# Lattice size(s) and stepsize(s)
dx = 0.01
dy = 0.01
Nx = int( 1. / dx)
Ny = int( 1. / dy)
x = np.array( range(Nx) )
y = np.array( range(Ny) )
latXX, latYY = np.meshgrid( x,y )

# Determine temporal stepsize by stability criterion
dx2 = dx**2
dy2 = dy**2
dt = (dx2 * dy2) / ( 2*D*(dx2 + dy2) )

# Number of steps
numTimeStep = 500

# Initial Conditions
# u = np.random.rand( Nx,Ny )
u = np.zeros( (Nx,Ny) )

# u[ int(Nx/2),int(Ny/2) ] = 1./Nx**2
radials = (latXX - int(Nx/2) )**2 + (latYY - int(Ny/2) )**2
circIdx = np.logical_and( radials < 50, radials > 20 )
u[ circIdx] = 1
ui = u

historyOfStates = []
tstart = time.time()
for i in range( numTimeStep ):
	state = np.copy(u)
	historyOfStates.append(state)
	
	diffusionTerm = D * spatialLaplacian( u,dx2,dy2 )
	reactionTerm = k * u * ( 1-u )
	
	u = ui + (diffusionTerm + reactionTerm) * dt
	ui = np.copy(u)

tfinish = time.time()

print "Time elapsed: ", tfinish-tstart, " (sec)"

