# TODO: Add comment
# 
# Author: Imagestation
###############################################################################
pairwise_difference <- function(x) {
	
	dx = outer(x,x,'-')
	diag(dx) = NA
	dx[upper.tri(dx)] = NA
	dx = as.vector(dx[is.finite(dx)])
	return(dx)
	
}