# get_PCFhat_stpp - Wrapper for PCFhat functionality in STPP

get_PCFhat_stpp <- function( xyt, s.region=NULL, t.region=NULL, u, v,
							h=hmsemin, label=NULL) {

	# Load libraries
	require("stpp")
	
	# parse inputs and/or default behavior
	# Use powers of 2 for FFT kernel estimation
	nt = 2^8
	nx = 2^11
	ny = 2^11
	
	# Set up the kenerl estimates of spatial and temporal distribution
	# of points
	
	xy = xyt[,1:2]
	t = xyt[,3]
	
	# Estimate temporal kernel density
	Mt = density( t,nt )
	mut = Mt$y[ findInterval( t, Mt$x) ] * dim(xyt)[1]
	
	# Estimate 2d spatial kernel density
	# Optimize t?e kernel bandwidth (h) by mean squared-error (MSE)
	#	analysis at set h values to scan
	#	Default: number of h-values: 50, max h-value: 4
	hmsemin = mse2d( as.points(xy), s.region, nsmse = 50, range = 10)
	hmsemin = hmsemin$h[ which.min(hmsemin$mse) ] # Argmin MSE
	
	Ms = kernel2d( as.points(xy), s.region, h=h, nx=nx, ny=ny)
	atx = findInterval( x=xyt[,1], vec = Ms$x)
	aty = findInterval( x=xyt[,2], vec = Ms$y)
	mhat = NULL
	for(i in 1:length(atx)) {
		mhat = c(mhat, Ms$z[atx[i],aty[i]])
	}
	
	g = PCFhat_label(xyt=xyt,
				lambda = mhat*mut/ dim(xyt)[1],
				dist = u, times = v,
				s.region = s.region, t.region = t.region,
				correction=TRUE, hs = h,label=label)
		
	return(g)
	
}

# get_STIKhat_stpp - Wrapper for STIKhat functionality in STPP

get_STIKhat_stpp <- function( xyt, s.region, t.region, u, v) {
	
	# Load libraries
	require("stpp")
	
	# Kernel estimation sizes
	nt = 2^8
	nx = 2^11
	ny = 2^11
	
	xy = xyt[,1:2]
	t = xyt[,3]
	
	# Estimate temporal kernel density
	Mt = density( t,nt )
	mut = Mt$y[ findInterval( t, Mt$x ) ] * dim(xyt)[1]
	
	# Estimate 2d spatial kernel density
	# Optimize the kernel bandwith (h) by mean squared-error (MSE)
	h = mse2d( as.points(xy), s.region, nsmse = 50, range = 10)
	h = h$h[ which.min(h$mse) ] #Argmin MSE
	
	Ms = kernel2d( as.points(xy) , s.region, h = h, nx=nx,ny=ny)
	
	# Construct XYT KDE domain
	atx = findInterval( x=xyt[,1], vec = Ms$x)
	aty = findInterval( x=xyt[,2], vec = Ms$y)
	mhat = NULL
	for(i in 1:length(atx)) mhat = c(mhat, Ms$z[atx[i],aty[i]])
	
	stik = STIKhat(xyt = xyt,
			lambda = mhat * mut / dim(xyt)[1],
			dist = u, times = v,
			infectious = TRUE)
	
	return(stik)
	
}
