#!/usr/bin/python

import numpy as np
import scipy.sparse.linalg as sparse
import pylab as pl
import include.CreateMovie as movie
from PIL import Image, ImageFilter
import matplotlib.pyplot as plt



# Number of grids
N = 200

# Spatial stepsizes
h = 1/(N+1.0)

# Temporal steps
k = h/2
TFinal = 1
num_time_steps = int(TFinal/k)

# Create lattice
x = np.linspace(0,1,N+2)
x = x[1:-1]

# Initial Conditions
u = np.transpose(np.mat(10*np.sin(np.pi*x)))

# Second-derivative matrix
data = np.ones(3,N)
data[1] = -2*data[1]
diags = [-1, 0, 1]
D2 = sparse.spdiags(data,diags,N,N)/(h**2)

I = sparse.identity(N)

data = []

for i in range(num_time_steps):
	A = (I - k/2 * D2)
	b = (I + k/2 * D2) *u
	u = np.transpose(np.mat( sparse.linalg.spsolve(A,b) ))

	data.append(u)

FPS = 20
num_frames = 10

def plotFunction( frame ):
	plt.plot(x, data[int(num_time_steps*frame / (FPS*num_frames))])
	plt.axis((0,1,0,10.1))

movie.CreateMovie(plotFunction,int(num_frames(FPS), FPS)

