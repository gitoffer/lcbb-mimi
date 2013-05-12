#!/usr/bin/python

import numpy as np
import scipy.sparse as sparse
import pylab as pl

from PIL import Image, ImageFilter
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
# --- Movie parameters ---
#		Frames per second


def createLattice( Nx,Ny ):
	lattice = np.matrix( np.ones( (Nx,Ny) ) )
	return lattice

def calcNextState( ui,dx2,dy2 ):
	uf = ui
	
	ddx = ( ui[2:,1:-1] - 2*ui[1:-1,1:-1] + ui[:-2,1:-1])/dx2 
	ddy = ( ui[1:-1,2:] - 2*ui[1:-1,1:-1] + ui[1:-1,:-2])/dy2

	uf[1:-1, 1:-1] = ui[1:-1 , 1:-1] + ddx + ddy

	return uf


# Diffusion constant
D = 0.5
# Reaction rate
k = 0.1

# Lattice size(s) and stepsize(s)
dx = 0.01
dy = 0.01
Nx = int( 1 / dx)
Ny = int( 1 / dy)

# Create lattice
lattice = createLattice( Nx,Ny )

# Determine temporal stepsize by stability criterion
dx2 = dx**2
dy2 = dy**2
dt = (dx2 * dy2) / ( 2*D*(dx2 + dy2))

# Number of steps
numTimeStep = 500

# Initial Conditions
currentState = np.random.rand( Nx,Ny )

historyOfStates = []

tstart = time.time()
for i in range( numTimeStep ):
	
	currentState = calcNextState( currentState,dx2,dy2 )
	currentState = currentState * D * dt
	historyOfStates.append(currentState)
	

tfinish = time.time()

print "Time elapsed: ", tfinish-tstart, " (sec)"


