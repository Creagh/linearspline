## ------------------------------------------------------------------------
library(linearspline)

## ------------------------------------------------------------------------
# Generate some data
x <- rnorm(100, 0, 1)
y <- 3 + pmin(2* x, 0) + rnorm(1, 0, 1)

# Fit a linear spline to the data
lmspline(x, y, nknots = 1)

## ------------------------------------------------------------------------
library(plyr)
suppressPackageStartupMessages(library(dplyr))

# Load the Gapminder dataset
gd_url <- "http://tiny.cc/gapminder"
gDat <- read.delim(file = gd_url)

# Extract the data for the countries in the continent Americas
aDat <- gDat %>% filter(continent == "Americas") %>% droplevels()

# Calculate the linear spline fit for each country in the Americas
# We will regress life expectancy on GDP per capita
spline_by_ctry <- dlply(aDat, ~country, function(x){lmspline(x$gdpPercap, x$lifeExp, nknots = 2)})

# Print the linear spline fitted to the country Canada
spline_by_ctry$Canada

## ----, fig.width = 6-----------------------------------------------------
library(ggplot2)

# Use the generated data from Example 1 above
lspline <- lmspline(x, y, nknots = 1)

# Plot the data and fitted spline using the pred.spline function
df <- data.frame(x,y)
ggplot(df, aes(x, y)) + geom_point() + ggtitle("Linear Spline with 1 Knot") +
	stat_function(fun = pred.spline, args = list(lspline), colour = 'blue', size = 0.7)

## ----, fig.width = 6, fig.height = 5-------------------------------------
# Create a plot of the fitted spline for the country Puerto Rico
aDat  %>% filter(country == "Puerto Rico") %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp)) + geom_point(size = 3) + 
  ggtitle("Life Expectancy by GDP per Capita for Puerto Rico") + 
	stat_function(fun = pred.spline,args = list(spline_by_ctry$'Puerto Rico'),colour = 'blue',size = 0.7)

## ----, fig.width = 6, fig.height = 5-------------------------------------
# Repeat the same procedure as above, but increase to 4 knots
spline_by_ctry4 <- dlply(aDat, ~country, function(x){lmspline(x$gdpPercap, x$lifeExp, nknots = 4)})

# Create a plot of the fitted spline for the country Chile
aDat  %>% filter(country == "Chile") %>% 
  ggplot(aes(x = gdpPercap, y = lifeExp)) + geom_point(size = 3) + 
  ggtitle("Life Expectancy by GDP per Capita for Chile") + 
	stat_function(fun = pred.spline,args = list(spline_by_ctry4$Chile),colour = 'blue',size = 0.7)

## ----, fig.width = 7, fig.height = 7-------------------------------------
# Import the Boston housing data
data(Boston, package='MASS')

# Create the linear spline fit with 4 knots
bstn_spline4 <- lmspline(Boston$ptratio, Boston$tax, nknots = 4)
# Create another linear spline fit with 3 knots
bstn_spline3 <- lmspline(Boston$ptratio, Boston$tax, nknots = 3)
# Create another linear spline fit with 2 knots
bstn_spline2 <- lmspline(Boston$ptratio, Boston$tax, nknots = 2)
# Create another linear spline fit with 1 knot
bstn_spline1 <- lmspline(Boston$ptratio, Boston$tax, nknots = 1)

# Create plots of the linear splines on the data
p <- ggplot(Boston, aes(x = ptratio, y = tax)) + geom_point()
p4 <- p + ggtitle("4 Knots") + 
	stat_function(fun = pred.spline, args = list(bstn_spline4), colour = 'purple', size = 0.7)
p3 <- p + ggtitle("3 Knots") + 
	stat_function(fun = pred.spline, args = list(bstn_spline3), colour = 'green', size = 0.7)
p2 <- p + ggtitle("2 Knots") + 
	stat_function(fun = pred.spline, args = list(bstn_spline2), colour = 'red', size = 0.7)
p1 <- p + ggtitle("1 Knot") + 
	stat_function(fun = pred.spline, args = list(bstn_spline1), colour = 'blue', size = 0.7)

# Arrange the plots in a grid
suppressPackageStartupMessages(library(gridExtra))
grid.arrange(p1, p2, p3, p4, ncol = 2)

