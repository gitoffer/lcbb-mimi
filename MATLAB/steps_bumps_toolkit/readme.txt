This ZIP file contains software for Matlab for performing step-filtering of signals
and associated utility functions, as described in [1-4] below.

(c) Max Little, 2010. If you use this code for your research, please cite the
appropriate reference as indicated in the comments at the top of each function.


References:

[1] M.A. Little, Nick S. Jones (2010) "Sparse Bayesian Step-Filtering for High-
Throughput Analysis of Molecular Machine Dynamics", in 2010 IEEE International
Conference on Acoustics, Speech and Signal Processing, 2010, ICASSP 2010
Proceedings (in press).

[2] M.A. Little, B.C. Steel, F. Bai, Y. Sowa, T. Bilyard, D.M. Mueller, R.M. Berry,
N.S. Jones (2010) "Steps and Bumps: Precision Extraction of Discrete States of
Molecular Machines using Physically-based, High-throughput Time Series Analysis",
arXiv:1004.1234v1 [q-bio.QM]

[3] B. Kalafut, K. Visscher (2008) "An objective, model-independent method for
detection of non-uniform steps in noisy signals", Comp. Phys. Comm.,
179(2008):716-723.

[4] S.H. Chung, R.A. Kennedy (1991), "Forward-backward non-linear filtering
technique for extracting small biological signals from noise", J. Neurosci. Methods. 
40(1):71-86.


ZIP file contents:

l1pwc.m
 - L1PWC (Total Variation Denoising) algorithm, as described in [2].

l1pwcar1.m
 - L1PWC-AR1 algorithm. Equivalent to Total Variation Denoising where the original
   input signal has specified autocorrelation at time lag 1. Algorithm described in
   [2].

l1pwclmax.m
 - Code to calculate the maximum useful value of lambda for the l1pwc algorithm.

ckfilter.m
 - An implementation of the Chung-Kennedy nonlinear filter. Algorithm described
   in [4] above.
   
kvsteps.m
 - A Matlab implementation of the Kalafut-Visscher step extraction algorithm,
   described in [3] above.

kvsteps_core.c
 - Matlab MEX code to implement the Kalafut-Visscher step extraction algorithm,
   called by kvsteps.m

kvsteps_core.mexw32
 - Above code compiled for Windows 32-bit platforms.

kvsteps_core.mexw64
 - Above code compiled for Windows 64-bit platforms.

ecf.m
 - Calculate the Empirical Characteristic Function (ECF) of a given time series, as
   described in [2].

ecf2pdf.m
 - Converts the ECF to the associated probability density function (PDF),
   as described in [2].

ecfshrink.m
 - Calculates the ECF of a time series, applies nonlinear (and/or linear) shrinkage
   to the coefficients, and then reconstructs the PDF. This algorithm is described
   in [2].

bfmsim.m
 - Generates simulated time series of stepping bacterial motors, as described in the
   supplementary material in [2].

exp2fit.m
 - Uses the method of moments to estimate the two rate constants of a double
   exponential distribution, as described in the supplementary material in [2].

exp2like.m
 - Calculates the negative log likelihood of a double exponential distribution model
   for a time series with two given rate constants. See supplementary material in [2].

exp2pdf.m
 - Evaluates the PDF of a double exponential distribution at the given values of
   the random variable with the given rate constants. See supplementary material
   in [2].

exp2rnd.m
 - Generates random numbers distributed according to a double exponential distribution
   with the given rate constants. See [2] for more details.

exp2stat.m
 - Calculates the mean and standard deviation of a double exponential distribution
   given the two rate constants. See [2] for more details.


Some of these functions are released under the terms of the GNU General Public Licence.
See the comments at the top of each function for further details. For those functions,
the following applies:

This program is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.
Permission to use, copy, modify, and distribute this software for any purpose
without fee is hereby granted, provided that this entire notice is included in all
copies of any software which is or includes a copy or modification of this software
and in all copies of the supporting documentation for such software. This program
is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU General Public License for more details.
