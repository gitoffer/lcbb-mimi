# Uses ggplot2 to visualze PCFs as returned by STPP
# 
# Author: xies
###############################################################################

require(gridExtra)
require(ggplot2)
require(reshape2)
require(scales)

d = melt(zscore)
d$zscore = d$value
d$dist = u[d$Var1]
d$times = v[d$Var2]
d$value = NULL; d$Var1 = NULL; d$Val2 = NULL;

p_emp = ggplot(data = d, aes(x=dist,y=times))
p_emp = p_emp + labs( title = "Empirical deviation from mean of simulations" )
p_emp = p_emp + labs(x = paste("Spatial lag (", mu, "m2)") )
p_emp = p_emp + labs(y = "Temporal lag (sec)")
p_emp = p_emp + geom_tile( aes(fill= as.numeric(abs(zscore) > 3)*zscore ) )
p_emp = p_emp + scale_fill_gradient2(
		low = "green",mid="black",high="magenta",
		midpoint = 0)
	# + scale_fill_gradient(low="white", high="red", limits = c(0,max(pcf[[embryoID]])))

p_bs = vector('list',10)

for ( i in 1:Nboot ){
	
	d = melt(pcfbs[[i]])
	d$pcf = d$value
	d$dist = u[d$Var1]
	d$times = v[d$Var2]
	d$value = NULL; d$Var1 = NULL; d$Val2 = NULL;
	
	p_bs[[i]] = ggplot(data = d, aes(x=dist,y=times))
	p_bs[[i]] = p_bs[[i]] + labs(title = "Bootstrapped PCF")
	p_bs[[i]] = p_bs[[i]] + labs(x = 
			expression(paste("Spatial lag (", mu, m^{2},")", sep=""))
			)
	p_bs[[i]] = p_bs[[i]] + labs(y = "Temporal lag (sec)")
	p_bs[[i]] = p_bs[[i]] + geom_tile( aes(fill=pcf) )
	p_bs[[i]] = p_bs[[i]] + scale_fill_gradient2(
			low = "black",mid="green",high="magenta",
			midpoint = (max(pcf[[embryoID]]) - 0)/2, limits= c(0, max(pcf[[embryoID]])) )
	
}

d = melt(Reduce('+',pcfbs)/ Nboot )
d$pcf = d$value
d$dist = u[d$Var1]
d$times = v[d$Var2]
d$value = NULL; d$Var1 = NULL; d$Val2 = NULL;
p = ggplot(data = d, aes( x = dist, y = times) )
p = p + labs(title = 'Average bootstrapped PCF')
p = p + labs(x = 'Spatial lag (mum^2)')
p = p + labs(y = 'Temporal lag (sec)')
p = p + geom_tile( aes( fill = pcf ) )
p = p + scale_fill_gradient2(
		low = "black",mid="green",high="magenta",
		midpoint = max(pcf[[embryoID]])/4, limits = c(0,max(pcf[[embryoID]])))

postscript( paste('~/Desktop/embryo',toString(embryoID),'.eps', sep = ''), width = 8.5, height = 11)
do.call( grid.arrange, list(p_emp, p) )
dev.off()

############### Pick a single spatial lag and find temporal correlation enveolope

get_matcol <- function(x) {return(x[6,])}
ctau_bs = do.call( rbind, lapply( pcfbs, get_matcol))
quantile_bs = apply( ctau_bs, 2, quantile, probs = c(0.05, 0.95))
mean_bs = apply(ctau_bs, 2, mean)

bsStats = data.frame(timelag = v, mean_bs)
bsStats$lb = quantile_bs[1,]
bsStats$ub = quantile_bs[2,]
bsStats$emp = g$pcf[6,]

p = ggplot(bsStats, aes(timelag))
p = p + labs( title = 
				expression(paste("Temporal pair-correlation at spatial lag ", Delta," = 5",mu,m^{2})))
p = p + labs( x = "Temporal lag (sec)")
p = p + labs( y = "Pair correlation function")
#p = p + geom_line( aes(y = mean_bs), color = 'red', size = 2)
p = p + geom_line( aes(y = emp), color = 'blue', size = 2)
p = p + geom_ribbon( aes(ymin = lb, ymax = ub), alpha = 0.2)

