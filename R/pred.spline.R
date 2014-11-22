#' Predict linear spline
#'
#' This function accepts a linear spline model and a set of explanatory
#' variables, for which it returns the predictions.
#' 
#' 
#' @param Vector \code{x} of explanatory values to predict from
#' @param Object \code{lspline} an lmspline object that contains
#' the fitted linear spline
#' @return Vector \code{y} the predictions for the given data and
#' linear spline fit
#' @keywords datagen
#' @author Creagh Briercliffe
#' @export
#' @examples
#' # Example 1
#' 
#' x <- rnorm(100, 0, 1)
#' y <- 3 + pmin(2* x, 0) + rnorm(1, 0, 1)
#' lspline <- lmspline(x, y, nknots = 1)
#' 
#' pred.spline(x, lspline)
#' 
#' # Example 2 - plotting with pred.spline
#' 
#' library(ggplot2)
#' df <- data.frame(x,y)
#' 
#' ggplot(df, aes(x, y)) + geom_point() + 
#' stat_function(fun = pred.spline, args = list(lspline), colour = 'blue', size = 0.7)

# The pred.spline function predicts values under the linear spline model
pred.spline <- function(x, lspline) {
	nknots  <- length(lspline$knots)
	fit <- lspline$fit
	knots <- lspline$knots
	
	y = coef(fit)[1] + coef(fit)[2] * x
	for(i in 1:nknots) {
		y = y + coef(fit)[i+2] * pmax(0, x - knots[i])
	}
	return(y)
}