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
	
	dxx = ( A[2: ,1:-1] - 2 * A[1:-1,1:-1] + A[ :-2,1:-1] ) / dx2
	dyy = ( A[1:-1,2: ] - 2 * A[1:-1,1:-1] + A[1:-1, :-2] ) / dy2

	lapA[1:-1,1:-1] = dxx + dyy

	return lapA


# Lattice size(s) and stepsize(s)
dx = 0.01
dy = 0.01
Nx = int( 1. / dx)
Ny = int( 1. / dy)
x = np.array( range( Nx ) )
y = np.array( range( Ny ) )
latXX, latYY = np.meshgrid( x,y )

# Determine temporal stepsize by stability criterion
dx2 = dx**2
dy2 = dy**2
dt = (dx2 * dy2) / ( 2 * 0.02 * (dx2 + dy2) )

# Number of steps
numTimeStep = 5000

# Initial Conditions
# u = np.random.rand( Nx,Ny )
u = np.zeros( (Nx,Ny) )
v = np.zeros( (Nx,Ny) )

## u[ int(Nx/2),int(Ny/2) ] = 1./Nx**2
#radials = (latXX - int(Nx/2) )**2 + (latYY - int(Ny/2) )**2
#circIdx = np.logical_and( radials < 50, radials > 20 )
#u[ circIdx] = 1
ui = u
vi = v
ui[1:-1,1:-1] = np.random.rand( Nx-2,Ny-2 )
vi[1:-1,1:-1] = np.random.rand( Nx-2,Ny-2 )

# Diffusion constants
D_u = 0.02
D_v = 0.05
# Degredation rates
d_u = 0.03
d_v = 0.08

tstart = time.time()
historyOfStates = []
for i in range( numTimeStep ):
	state = np.copy(u)
	historyOfStates.append(state)
	
	# Production terms
	F_u = 0.08 * u - 0.08 * v + 0.03
	F_u[F_u < 0] = 0
	F_u[F_u > 0.2] = 0.2

	G_v = 0.1 * u - 0.0 * v - 0.15
	G_v[G_v < 0] = 0
	G_v[G_v > 0.5] = 0.5
	
	du = ( F_u - d_u * u + D_u * spatialLaplacian( u,dx2,dy2 ) ) * dt
	dv = ( G_v - d_v * v + D_v * spatialLaplacian( v,dx2,dy2 ) ) * dt
	
	u = ui + du
	v = vi + dv

	ui = np.copy(u)
	vi = np.copy(v)

tfinish = time.time()

print "Time elapsed: ", tfinish-tstart, " (sec)"

