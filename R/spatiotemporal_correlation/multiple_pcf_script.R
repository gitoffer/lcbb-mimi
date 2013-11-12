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

### Estimate overall PCF from all embryos

g = get_PCFhat_stpp(
		xyt = as.matrix(f[c('x','y','t')]),
		s.region=s.region,t.region=c(min(f$t),max(f$t)),
		u=u,v=v, label = get_embryoID(fitID))

###### Load bootstrapped pulses ######

fbs <- vector('list', Nboot)
Nboot = 50
for (n in 1:Nboot) {
	
	for (embryoID in 1:num_emb) {
	
		raw = as.matrix(read.csv(bs_filepath(embryoID,n)))
		
		thisf = data.frame( fitID = raw[,1],
				x = raw[,2], y = raw[,3], t = raw[,4]
		)
		
		thisf$behavior = cluster_names[raw[,5]]
		
		if (embryoID > 1) { fbs[[n]] = rbind(fbs[[n]],thisf) }
		else {fbs[[n]] = thisf}
		
	}
}

###### Get bootstrapped PCF
pcfbs <- vector('list', Nboot)
gbs <- vector('list',Nboot)
for (n in 1:Nboot) {
	
	gbs[[n]] = get_PCFhat_stpp(
			xyt = as.matrix(fbs[[n]][c('x','y','t')]),
			s.region = s.region, t.region = t.region,
			u=u, v=v, h = 1.4,
			label = get_embryoID(fbs[[n]]$fitID) )
	
	pcfbs[[n]] = gbs[[n]]$pcf
	
	print(paste('Done with: ', toString(n)))
	
}

