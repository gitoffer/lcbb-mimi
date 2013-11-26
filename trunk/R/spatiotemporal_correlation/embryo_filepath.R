# Author: xies
###############################################################################


##### Construct filepaths

filepath <- function (embryoID) {
	return( paste('~/Desktop/Pulse xyt csv/Embryo ', toString(embryoID),
					'/emb', toString(embryoID), '_emp.csv',
					sep = '') )
}

bs_filepath <- function (embryoID,nboot) {
	return( paste('~/Desktop/Pulse xyt csv/Embryo ', toString(embryoID),
					'/simulated/emb', toString(embryoID), '_N', toString(nboot), '.csv',
					sep = '') )
}

sbox_filepath <- function (embryoID) {
	return( paste('~/Desktop/Pulse xyt csv/Embryo ', toString(embryoID),
					'/sbox', toString(embryoID), '.csv',
					sep = '') )
}

# a function to extract the first digit from a number
get_leading_digit <- function(k){
	as.numeric(head(strsplit(as.character(k),'')[[1]],n=1))
}
get_embryoID <- function(fitIDs) {rbind(lapply(fitIDs,get_leading_digit))}
