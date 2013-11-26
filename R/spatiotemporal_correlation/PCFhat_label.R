# TODO: Add comment
# 
# Author: Imagestation
###############################################################################


PCFhat_label <- function(xyt, s.region, t.region, dist, times, lambda, ks="box", hs, kt="box", ht, correction = TRUE, label) 
{
	require(splancs)
	require(KernSmooth)
	
	if (missing(s.region)) s.region <- sbox(xyt[,1:2],xfrac=0.01,yfrac=0.01)
	if (missing(t.region)) t.region <- range(xyt[,3],na.rm=T)
	
	pts <- xyt[,1:2]
	xytimes <- xyt[,3]
	ptsx <- pts[, 1]
	ptsy <- pts[, 2]
	ptst <- xytimes
	npt <- length(ptsx)
	ndist <- length(dist)
	dist <- sort(dist)
	ntimes <- length(times)
	times <- sort(times)
	bsupt <- max(t.region)
	binft <- min(t.region)
	
	area <- areapl(s.region)*(bsupt-binft)
	
	np <- length(s.region[, 1])
	polyx <- c(s.region[, 1], s.region[1, 1])
	polyy <- c(s.region[, 2], s.region[1, 2])
	pcfhat <- array(0, dim = c(ndist,ntimes))
	
	frac=1	
	if (missing(hs))
	{
		d=dist(pts)
		if (ks=="gaussian") hs = dpik(d,kernel="normal",range.x=c(min(d),max(d)/frac))
		else hs = dpik(d,kernel=ks,range.x=c(min(d),max(d)/frac))
	} 
	if (missing(ht))
	{
		d=dist(ptst)
		if (kt=="gaussian") ht = dpik(d,kernel="normal",range.x=c(min(d),max(d)/frac))
		else ht = dpik(d,kernel=kt,range.x=c(min(d),max(d)/frac))
	}
	
	kernel=c(ks=ks,hs=hs,kt=kt,ht=ht)
	
	if (ks=="box") ks=1 	
	else if (ks=="epanech") ks=2
	else if (ks=="gaussian") ks=3
	else if (ks=="biweight") ks=4
	
	if (kt=="box") kt=1 	
	else if (kt=="epanech") kt=2
	else if (kt=="gaussian") kt=3
	else if (kt=="biweight") kt=4
	
	if(missing(lambda))
	{
		misl <- 1
		lambda <- rep(1,npt)
	}
	else misl <- 0
	if (length(lambda)==1) lambda <- rep(lambda,npt)
	if (correction==TRUE){edg <- 1} else  edg <- 0
	storage.mode(pcfhat) <- "double"
	
	if (area>10) lambda <- lambda*area
	
	nev <- rep(0,ntimes)
	
	klist <- .Fortran("pcffunction_lab", as.double(ptsx),
			as.double(ptsy), as.double(ptst), 
			as.integer(npt), as.double(polyx),
			as.double(polyy), as.integer(np),
			as.double(dist), as.integer(ndist),
			as.double(times), as.integer(ntimes),
			as.double(bsupt), as.double(binft),
			as.double(lambda), as.integer(ks), as.integer(kt),
			as.integer(edg), as.double(hs),
			as.double(ht), (pcfhat), as.integer(label))
	pcfhat <- klist[[20]]
	
	if (misl==1) 
	{
		if (area>10)
			pcfhat <- ((area^3)/(npt*(npt-1)))*pcfhat
		else
			pcfhat <- (area/(npt*(npt-1)))*pcfhat
	}
	else
	{
		if (area>10)
			pcfhat <- pcfhat*area
		else
			pcfhat <- pcfhat/area
	}
	
	pcfhat <- pcfhat/(4*pi*dist)
	
	if(dist[1]==0) pcfhat[1,]=NA
	if(times[1]==0) pcfhat[,1]=NA
	
	invisible(return(list(pcf=pcfhat,dist=dist,times=times,kernel=kernel)))  
}
