suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(ggplot2))

gd_url <- "http://tiny.cc/gapminder"
gDat <- read.delim(file = gd_url)

oDat <- gDat %>% filter(continent == "Oceania") %>% droplevels()

(spline <- lmspline(oDat$gdpPercap, oDat$lifeExp, 4, na.rm = TRUE))
(spline <- lmspline(oDat$gdpPercap, oDat$lifeExp, 0, na.rm = TRUE))
(spline <- lmspline(oDat$gdpPercap, oDat$lifeExp, 1, na.rm = TRUE))
(spline <- lmspline(oDat$gdpPercap, oDat$lifeExp, 2.5, na.rm = TRUE))
(spline <- lmspline(gDat$gdpPercap, gDat$lifeExp, 2, na.rm = TRUE))

x <- rnorm(100, 0, 1)
y <- 3 + pmin(2* x, 0) + rnorm(1, 0, 1)
lmspline(x, y)
lmspline(x, y, nknots = 3, na.rm = FALSE)

lspline <- lmspline(x, y, nknots = 1)
pred.spline(x, lspline)

df <- data.frame(x,y)
ggplot(df, aes(x, y)) + geom_point() +
	stat_function(fun = pred.spline, args = list(lspline), colour = 'blue', size = 0.7)
