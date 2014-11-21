#' Linear spline regression
#'
#' This function returns a list of coefficients and knots used
#' to fit a linear spline to the given data.
#' 
#' Linear spline regression works by fitting piece-wise linear 
#' functions to segments of the data between connecting points, 
#' called knots. One benefit of linear spline regression is that
#' it can produce a better local fit of the data between the knots. 
#' 
#' @param Vector \code{x} of the numeric valued data
#' @param Vector \code{y} of the responses
#' @param Numeric \code{num_knots} a positive integer corresponding
#' to the number of knots
#' @param Logical \code{na.rm} takes value \code{TRUE} if \code{NA} 
#' values should be ignored
#' @return List containing the fitted model and the vector of knots used.
#' @keywords models
#' @author Creagh Briercliffe
#' @export
#' @examples
#' lmspline(x, y)
#' lmspline(num_knots = 3, x, y, na.rm = FALSE)

lmspline <- function(x, y, num_knots = 1, na.rm = FALSE) {
	
	# Check to see that num_knots is a numeric value
	if(!is.numeric(num_knots)) {
		stop('The number of knots must be a numeric value.')
		
		# Check to see that num_knots is a positive integer 
	} else if(num_knots%%1 != 0 || num_knots <= 0) {
		stop('The number of knots must be a positive integer.')
	}
	
	# Default: Choose the knots as evenly spaced quantiles of the data
	knots <- x %>% quantile((1:num_knots) / (num_knots + 1), na.rm = na.rm)
	
	# Create the matrix of covariates to pass to the lm function
	m <- create.cov(x, knots)
	
	# Calculate the spline regression function on the covariate matrix using the base R lm function
	fit <- lm(y ~ m)
	
	# Return the fitted function and the knots in a list
	return(list(fit = fit, knots = knots))
}

# The create.cov subroutine creates a covariance matrix to be used in the linear regression
create.cov <- function(x, knots) {
	num_knots <- length(knots)
	
	# Begin by initializing a matrix of zeroes with the apporpriate dimensions
	m <- matrix(0, nrow = length(x), ncol = num_knots + 1)
	
	# Fill the covariate matrix with the appropriate values based on the spline function
	m[,1] <- x
	for(i in 1:num_knots) {
		m[, i+1] <- pmax(0, x - knots[i])
	}
	return(m)
}

# The pred.spline function predicts values under the linear spline model
pred.spline <- function(x, lspline) {
	num_knots  <- length(lspline$knots)
	fit <- lspline$fit
	knots <- lspline$knots
	
	y = coef(fit)[1] + coef(fit)[2] * x
	for(i in 1:num_knots) {
		y = y + coef(fit)[i+2] * pmax(0, x - knots[i])
	}
	return(y)
}