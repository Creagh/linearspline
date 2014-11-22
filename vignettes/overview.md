Package Overview
----------------

This package provides functions for fitting a linear regression spline
to a set of data and for predicting responses from the spline model to
allow for analysis and plotting.

Linear spline regression works by fitting piece-wise linear functions to
segments of the data between connecting points, called **knots**. One
benefit of linear spline regression is that it can produce a better
local fit of the data between the knots. This flexible model can help
capture non-linear trends simply by adjusting the number of the knots.

Functions
---------

First, load the package:

    library(linearspline)

### lmspline

This is the main function for the package that returns a list of
coefficients and knots used to fit a linear spline to the given data.
Given a number of knots, `nknots`, this function will place `nknots`
knots at evenly spaced quantiles of the data, and fit a linear
regression spline.

The `lmspline` function relies on a helper function, `create.cov` to
calculate the matrix of covariates to be fit using regression methods.
The `create.cov` function is not exported with the package and hence
cannot be called directly by the user.

*Example 1:*

    # Generate some data
    x <- rnorm(100, 0, 1)
    y <- 3 + pmin(2* x, 0) + rnorm(1, 0, 1)

    # Fit a linear spline to the data
    lmspline(x, y, nknots = 1)

    ## $fit
    ## 
    ## Call:
    ## lm(formula = y ~ m)
    ## 
    ## Coefficients:
    ## (Intercept)           m1           m2  
    ##        2.30         1.97        -1.99  
    ## 
    ## 
    ## $knots
    ##     50% 
    ## 0.03406

Now, for a more involved example using the Gapminder dataset.

*Example 2:*

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

    ## $fit
    ## 
    ## Call:
    ## lm(formula = y ~ m)
    ## 
    ## Coefficients:
    ## (Intercept)           m1           m2           m3  
    ##    6.39e+01     4.88e-04     7.51e-05    -2.27e-04  
    ## 
    ## 
    ## $knots
    ## 33.33% 66.67% 
    ##  18006  26437

### pred.spline

This function accepts a linear spline model (created using `lmspline`)
and a set of explanatory variables, for which it returns the
predictions. This function can be used for prediction on new data as
well as for plotting.

*Example 1:*

    library(ggplot2)

    # Use the generated data from Example 1 above
    lspline <- lmspline(x, y, nknots = 1)

    # Plot the data and fitted spline using the pred.spline function
    df <- data.frame(x,y)
    ggplot(df, aes(x, y)) + geom_point() + ggtitle("Linear Spline with 1 Knot") +
        stat_function(fun = pred.spline, args = list(lspline), colour = 'blue', size = 0.7)

![plot of chunk
unnamed-chunk-4](./overview_files/figure-markdown_strict/unnamed-chunk-4.png)

*Example 2:*

    # Create a plot of the fitted spline for the country Puerto Rico
    aDat  %>% filter(country == "Puerto Rico") %>% 
      ggplot(aes(x = gdpPercap, y = lifeExp)) + geom_point(size = 3) + 
      ggtitle("Life Expectancy by GDP per Capita for Puerto Rico") + 
        stat_function(fun = pred.spline,args = list(spline_by_ctry$'Puerto Rico'),colour = 'blue',size = 0.7)

![plot of chunk
unnamed-chunk-5](./overview_files/figure-markdown_strict/unnamed-chunk-5.png)

Let's look at one more example using more knots this time.

*Example 3:*

    # Repeat the same procedure as above, but increase to 4 knots
    spline_by_ctry4 <- dlply(aDat, ~country, function(x){lmspline(x$gdpPercap, x$lifeExp, nknots = 4)})

    # Create a plot of the fitted spline for the country Chile
    aDat  %>% filter(country == "Chile") %>% 
      ggplot(aes(x = gdpPercap, y = lifeExp)) + geom_point(size = 3) + 
      ggtitle("Life Expectancy by GDP per Capita for Chile") + 
        stat_function(fun = pred.spline,args = list(spline_by_ctry4$Chile),colour = 'blue',size = 0.7)

![plot of chunk
unnamed-chunk-6](./overview_files/figure-markdown_strict/unnamed-chunk-6.png)

Theory
------

A linear spline is a continuous function formed by connecting linear
segments. The points where the segments connect are called the knots of
the spline. Consider the following family of functions for one variable,
*x*.

\$\$ f\_k(x) = (x - \\kappa\_k)\_+ = 
\\begin{cases} 
x - \\kappa\_k & \\text{ if } x \> \\kappa\_k \\\\
0 & \\text{ otherwise }
\\end{cases} \$\$

where *κ*<sub>*k*</sub>, 1 ≤ *k* ≤ *K*,  are the knots (to be chosen).
Then the equation for the linear spline is given by the following.

E(*Y*∣*x*) = *β*<sub>0</sub> + *β*<sub>1</sub>*x* + ∑<sub>*k* = 1</sub><sup>*K*</sup>*β*<sub>*k* + 1</sub>*f*<sub>*k*</sub>(*x*)

The knots for a spline can be chosen arbitrarily, although it is
customary to select them based on sample quantiles of the observed data,
*x*. The `lmspline` function accepts as an argument the number of knots
(*K*, in this formula). Then, the knots *k* from 1 to *K* are chosen as
equally spaced sample quantiles of the data, by the following formula.

\$\$ \\kappa\_k = \\left( \\frac{k}{K + 1} \\right) 100\\% \\text{  quantile of the observed \$x\$}\$\$

Thus, the design matrix for a dataset of size *n*, computed by the
helper function `create.cov`, will take the following form.

\$\$ \\mathbf{X} =
 \\begin{pmatrix}
  1 & x\_1 & (x\_1 - \\kappa\_1)\_+ & \\cdots & (x\_1 - \\kappa\_K)\_+ \\\\
  1 & x\_2 & (x\_2 - \\kappa\_1)\_+ & \\cdots & (x\_2 - \\kappa\_K)\_+ \\\\
  \\vdots  & \\vdots  & \\vdots & \\ddots & \\vdots  \\\\
  1 & x\_n & (x\_n - \\kappa\_1)\_+ & \\cdots & (x\_n - \\kappa\_K)\_+
 \\end{pmatrix}\$\$

Once we have the above design matrix, fitting a linear spline simply
reverts to a linear regression problem, where the coefficients are
chosen as the least squares solution to the equation
**Y** = *β***X** + *ε*.

More Examples
-------------

One final exapmle using Boston housing data available in the library
`MASS`.

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

![plot of chunk
unnamed-chunk-7](./overview_files/figure-markdown_strict/unnamed-chunk-7.png)

Discussion
----------

As an idea for future work, it would be nice to extend the `lmspline`
function to accept either the number of knots to choose, or a vector of
already chosen knots. In this way, the user could then specify the
placement of the knots, in order to better fit a dataset that can be
examined beforehand.
