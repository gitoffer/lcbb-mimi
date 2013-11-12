# TODO: Add comment
# 
# Author: xies
###############################################################################

num_emb = 2

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
sbox <- vector("list", num_emb)
tbox <- vector("list", num_emb)

# User the same kernel size as the empirical distribution

for (embryoID in 1:num_emb) {
	
	print (paste( filepath(embryoID)) )
	f[[embryoID]] = as.3dpoints(as.matrix( read.csv(filepath(embryoID)) ))
	sbox[[embryoID]] = as.matrix(read.csv( sbox_filepath(embryoID)) )
	tbox[[embryoID]] = c( min(f[[embryoID]][,3]), max(f[[embryoID]][,3]) )
	
}


