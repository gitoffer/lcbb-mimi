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
					'/random_cell/emb', toString(embryoID), '_N', toString(nboot), '.csv',
					sep = '') )
}

sbox_filepath <- function (embryoID) {
	return( paste('~/Desktop/Pulse xyt csv/Embryo ', toString(embryoID),
					'/sbox', toString(embryoID), '.csv',
					sep = '') )
}
