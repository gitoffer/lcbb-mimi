# TODO: Work more explicitly with dataframes
# 
# Author: xies
###############################################################################

num_emb = 5
u = seq(1,30)
v = seq(1,100)

### Load embryo pulsing location into a dataframe

cluster_names = c('Ratcheted',
				'Ratcheted - early',
				'Ratcheted -delayed',
				'Unratcheted',
				'Stretched',
				'N/A')

for (embryoID in 1:num_emb) {
	
	raw = as.matrix(read.csv(filepath(embryoID)))
	
	thisf = data.frame( fitID = raw[,1],
			x = raw[,2], y = raw[,3], t = raw[,4])
	
	thisf$behavior = cluster_names[raw[,5]] 
			
	if (embryoID > 1) { f = rbind(f,thisf) }
	else {f = thisf}
	
}

### Get PCF for each embryo

for (embryoID in 1:num_emb) {
	
	
	
}

###### Get empirical PCF
#
#
#
#f <- vector("list", num_emb) # create list
#l <- vector("list", num_emb) # create list
#g1 <- vector("list", num_emb)
#g4 <- vector("list", num_emb)
#pcf1 <- vector("list", num_emb)
#pcf4 <- vector("list", num_emb)
#sbox <- vector("list", num_emb)
#tbox <- vector("list", num_emb)
#spatial_kernels <- vector("list", num_emb)
#
## User the same kernel size as the empirical distribution
#
#for (embryoID in 1:num_emb) {
#	
#	print (paste( filepath(embryoID)) )
#	foo = as.matrix( read.csv(filepath(embryoID)) )
#	f[[embryoID]] = as.3dpoints( foo[,1:3] )
#	l[[embryoID]] = foo[,4]
#	sbox[[embryoID]] = as.matrix(read.csv( sbox_filepath(embryoID)) )
#	tbox[[embryoID]] = c( min(f[[embryoID]][,3]), max(f[[embryoID]][,3]) )
#	
#	g1[[embryoID]] = get_PCFhat_stpp(xyt = f[[embryoID]],
#			s.region = sbox[[embryoID]], t.region = tbox[[embryoID]],
#			u, v, h = 5, l[[embryoID]] == 1)
#	
#	g4[[embryoID]] = get_PCFhat_stpp(xyt = f[[embryoID]],
#			s.region = sbox[[embryoID]], t.region = tbox[[embryoID]],
#			u, v, h = 5, l[[embryoID]] == 4)
#	
#	spatial_kernels[[embryoID]] = 5
#	
#	pcf1[[embryoID]] = g1[[embryoID]]$pcf
#	pcf4[[embryoID]] = g4[[embryoID]]$pcf
#	
#}
#
###### Get bootstrapped PCF
#Nboot = 20
#embryoID = 2
#fbs <- vector('list', Nboot)
#lbs <- vector('list', Nboot)
#gbs1 <- vector('list', Nboot)
#gbs4 <- vector('list', Nboot)
#pcfbs1 <- vector('list', Nboot)
#pcfbs4 <- vector('list', Nboot)
#
#for (n in 1:Nboot) {
#	
#	foo = as.matrix( read.csv(bs_filepath(embryoID,n)) )
#	fbs[[n]] = as.3dpoints(foo[,1:3])
#	lbs[[n]] = foo[,4]
#	gbs1[[n]] = get_PCFhat_stpp( xyt = fbs[[n]], s.region = sbox[[embryoID]], t.region = tbox[[embryoID]],
#			u,v, h = spatial_kernels[[embryoID]], lbs[[embryoID]] == 4)
#	gbs4[[n]] = get_PCFhat_stpp( xyt = fbs[[n]], s.region = sbox[[embryoID]], t.region = tbox[[embryoID]],
#			u,v, h = spatial_kernels[[embryoID]], lbs[[embryoID]] == 4)
#	pcfbs1[[n]] = gbs1[[n]]$pcf
#	pcfbs4[[n]] = gbs4[[n]]$pcf
#	
#}
#
