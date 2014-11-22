#' Calculate the covariance matrix
#'
#' This is a helper function to calculated the covariance
#' matrix for the linear regression spline function. This
#' function is not to be exported. 
#' 
#' @param Vector \code{x} the explanatory variables
#' @param Vector \code{knots} the knots to be used
#' @return Matrix containing the covariates for linear spline regression
#' @keywords array
#' @author Creagh Briercliffe

# This is a helper function -- not to be exported
# The create.cov subroutine creates a covariance matrix to be used in the linear regression
create.cov <- function(x, knots) {
	nknots <- length(knots)
	
	# Begin by initializing a matrix of zeroes with the apporpriate dimensions
	m <- matrix(0, nrow = length(x), ncol = nknots + 1)
	
	# Fill the covariate matrix with the appropriate values based on the spline function
	m[,1] <- x
	for(i in 1:nknots) {
		m[, i+1] <- pmax(0, x - knots[i])
	}
	return(m)
}