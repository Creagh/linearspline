suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(ggplot2))

gd_url <- "http://tiny.cc/gapminder"
gDat <- read.delim(file = gd_url)

oDat <- gDat %>% filter(continent == "Oceania") %>% droplevels()

(spline <- lmspline(oDat$gdpPercap, oDat$lifeExp, 4, na.rm = TRUE))
(spline <- lmspline(oDat$gdpPercap, oDat$lifeExp, 0, na.rm = TRUE))
(spline <- lmspline(oDat$gdpPercap, oDat$lifeExp, 1, na.rm = TRUE))
(spline <- lmspline(oDat$gdpPercap, oDat$lifeExp, 2.5, na.rm = TRUE))
