# TODO: Add comment
# 
# Author: xies
###############################################################################

num_emb = 5
u = seq(1,30)
v = seq(1,100)

##### Construct filepaths

filepath <- function (embryoID) {
	return( paste('~/Desktop/Pulse xyt csv/Embryo ', toString(embryoID),
					'/emb', toString(embryoID), '_emp.csv',
					sep = '') )
}

bs_filepath <- function (embryoID,nboot) {
	return( paste('~/Desktop/Pulse xyt csv/Embryo ', toString(embryoID),
					'/emb', toString(embryoID), '_bs_N', toString(nboot), '.csv',
					sep = '') )
}

sbox_filepath <- function (embryoID) {
	return( paste('~/Desktop/Pulse xyt csv/Embryo ', toString(embryoID),
					'/sbox', toString(embryoID), '.csv',
					sep = '') )
}

###

###### Get empirical PCF

f <- vector("list", num_emb) # create list
g <- vector("list", num_emb)
pcf <- vector("list", num_emb)
sbox <- vector("list", num_emb)
tbox <- vector("list", num_emb)
spatial_kernels <- vector("list", num_emb)

# User the same kernel size as the empirical distribution

for (embryoID in 1:num_emb) {
	
	print (paste( filepath(embryoID)) )
	f[[embryoID]] = as.3dpoints(as.matrix( read.csv(filepath(embryoID)) ))
	sbox[[embryoID]] = as.matrix(read.csv( sbox_filepath(embryoID)) )
	tbox[[embryoID]] = c( min(f[[embryoID]][,3]), max(f[[embryoID]][,3]) )
	
	g[[embryoID]] = get_PCFhat_stpp(xyt = f[[embryoID]], s.region = sbox[[embryoID]], t.region = tbox[[embryoID]],
			u, v, h = 2)
	spatial_kernels[[embryoID]] = 2
	pcf[[embryoID]] = g[[embryoID]]$pcf
	
}

##### Get bootstrapped PCF
Nboot = 20
embryoID = 4
fbs <- vector('list', Nboot)
gbs <- vector('list', Nboot)
pcfbs <- vector('list', Nboot)

for (n in 1:Nboot) {
	
	fbs[[n]] = as.3dpoints(as.matrix( read.csv(bs_filepath(embryoID,n)) ))
	gbs[[n]] = get_PCFhat_stpp( xyt = fbs[[n]], s.region = sbox[[embryoID]], t.region = tbox[[embryoID]],
			u,v, h = spatial_kernels[[embryoID]])
	pcfbs[[n]] = gbs[[n]]$pcf
	
}

