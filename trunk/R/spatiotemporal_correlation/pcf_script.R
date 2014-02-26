# TODO: Handle interruptible flow?
# 
# Author: xies
###############################################################################

eIDs = c(1:5)
num_embryo = length(eIDs)
u = seq(1,30)
v = seq(1,100)

### Load embryo pulsing location into a dataframe

cluster_names = c('Ratcheted',
				'Ratcheted - early',
				'Ratcheted -delayed',
				'Unratcheted',
				'Stretched',
				'N/A')
f =NULL
for (embryoID in eIDs) {
	
	print(paste(filepath(embryoID)))
	raw = as.matrix(read.csv(filepath(embryoID)))
	thisf = data.frame( fitID = raw[,1],
			x = raw[,2], y = raw[,3], t = raw[,4])
#	thisf$behavior = raw[,5]
			
	if (embryoID > eIDs[1]) { f = rbind(f,thisf) }
	else {f = thisf}
	
}

attach(f)
s.region = matrix(
		c(min(x)-1,min(x)-1,max(x),max(x),min(y)-1,max(y),max(y),min(y)-1),
		nrow = 4, ncol=2)
t.region = c(min(t)-1,max(t)+1)
detach(f)

### Get all eta,tau pairs and plot them first
dx = pairwise_difference(f$x)
dy = pairwise_difference(f$y)
ds = sqrt(dx^2 + dy^2)
dt = pairwise_difference(f$t)
plot(ds,dt,cex=0.1,xlim=c(0,30),ylim=c(0,100))

### Estimate overall PCF from all embryos

dyn.load('~/Desktop/Code Library/Fortran/PCF/kernel_pcf_embryos.so')
dyn.load('~/Desktop/Code Library/Fortran/PCF/kernel_pcf_embryos_labels.so')

h_values = 3.5

g = get_PCFhat_stpp(
		xyt = as.matrix(f[c('x','y','t')]),
		s.region=s.region,t.region=t.region,
		u=u,v=v, embryoID = as.numeric(get_embryoID(f$fitID) ),
		h = h_values)

###### Load bootstrapped pulses ######

Nboot = 50
fbs <- NULL

for (n in 1:Nboot) {
	
	for (embryoID in eIDs) {
	
		print(paste('EmbryoID: ', embryoID, ' iteration: ', n))
		raw = as.matrix(read.csv(bs_filepath(embryoID,n)))
		
		thisf = data.frame( fitID = raw[,1],
				x = raw[,2], y = raw[,3], t = raw[,4],
				bootID = n
		)
		
#		thisf$behavior = raw[,5]

		if (embryoID == eIDs[1] && n == 1) { fbs = thisf }
		else {fbs = rbind(fbs,thisf)}
		
	}
	
}

### Get all eta,tau pairs and plot them first
dx = pairwise_difference(fbs[fbs$bootID == 4,]$x)
dy = pairwise_difference(fbs[fbs$bootID == 4,]$y)
ds = sqrt(dx^2 + dy^2)
dt = pairwise_difference(fbs[fbs$bootID == 4,]$t)
plot(ds,dt,cex=0.1,xlim=c(0,30),ylim=c(0,100))

###### Get bootstrapped PCF ######

gbs <- vector('list',Nboot)
pcfbs <- vector('list', Nboot)
for (n in 1:Nboot) {
	
	gbs[[n]] = get_PCFhat_stpp(
			
			xyt = as.matrix(fbs[fbs$bootID == n,][c('x','y','t')]),
			s.region = s.region, t.region = t.region,
			u=u, v=v, h = h_values,
			embryoID = as.numeric(get_embryoID(fbs[fbs$bootID == n,]$fitID))
	)
	
	pcfbs[[n]] = gbs[[n]]$pcf
	
	print(paste('Done with: ', toString(n)))
	
}

postscript( paste('~/Desktop/embryo',eIDs,'.eps'),horizontal=FALSE,height=11,width=8.5)
par(mfrow=c(2,1))
image.plot(u,v,g$pcf,zlim=c(0,1))
image.plot(u,v,Reduce('+',pcfbs)/Nboot,zlim=c(0,1))
dev.off()
