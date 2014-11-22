#' Linear spline regression
#'
#' This function returns a list of coefficients and knots used
#' to fit a linear spline to the given data. Given a number of knots,
#'  \code{nknots}, this function will place \code{nknots} knots at 
#'  evenly spaced quantiles of the data, and fit a linear regression spline.
#' 
#' Linear spline regression works by fitting piece-wise linear 
#' functions to segments of the data between connecting points, 
#' called knots. One benefit of linear spline regression is that
#' it can produce a better local fit of the data between the knots. 
#' 
#' @param Vector \code{x} of the numeric valued data
#' @param Vector \code{y} of the responses
#' @param Numeric \code{nknots} a positive integer corresponding
#' to the number of knots
#' @param Logical \code{na.rm} takes value \code{TRUE} if \code{NA} 
#' values should be ignored
#' @return List containing the fitted model and the vector of knots used.
#' @keywords models
#' @author Creagh Briercliffe
#' @export
#' @examples
#' # Example 1
#' x <- rnorm(100, 0, 1)
#' y <- 3 + pmin(2* x, 0) + rnorm(1, 0, 1)
#' lmspline(x, y)
#' 
#' # Example 2
#' lmspline(x, y, nknots = 3, na.rm = FALSE)
#' 
#' # Example 3
#' gd_url <- "http://tiny.cc/gapminder"
#' gDat <- read.delim(file = gd_url)
#' lmspline(gDat$gdpPercap, gDat$lifeExp, 2, na.rm = TRUE)

lmspline <- function(x, y, nknots = 1, na.rm = FALSE) {
	
	# Check to see that nknots is a numeric value
	if(!is.numeric(nknots)) {
		stop('The number of knots must be a numeric value.')
		
		# Check to see that nknots is a positive integer 
	} else if(nknots%%1 != 0 || nknots <= 0) {
		stop('The number of knots must be a positive integer.')
	}
	
	# Default: Choose the knots as evenly spaced quantiles of the data
	knots <- quantile(x, (1:nknots) / (nknots + 1), na.rm = na.rm)
	
	# Create the matrix of covariates to pass to the lm function
	m <- create.cov(x, knots)
	
	# Calculate the spline regression function on the covariate matrix using the base R lm function
	fit <- lm(y ~ m)
	
	# Return the fitted function and the knots in a list
	return(list(fit = fit, knots = knots))
}