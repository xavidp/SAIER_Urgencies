# Xavier de Pedro - Aj. BCN - AAI
# Copyleft 2017 - xdepedro@bcn.cat
#
# Geografic maps with AAI data on top 
# https://cran.r-project.org/web/packages/leaflet.minicharts/vignettes/introduction.html
#
if (!require("pacman")) install.packages("pacman")
#pacman::p_load_gh("trinker/textreadr")
pacman::p_load(leaflet.minicharts)
library(leaflet.minicharts)

# Data
data("eco2mix")
head(eco2mix)

# Renewable productions in 2016
library(dplyr)

prod2016 <- eco2mix %>%
  mutate(
    renewable = bioenergy + solar + wind + hydraulic,
    non_renewable = total - bioenergy - solar - wind - hydraulic
  ) %>%
  filter(grepl("2016", month) & area != "France") %>%
  select(-month) %>%
  group_by(area, lat, lng) %>%
  summarise_all(sum) %>%
  ungroup()

head(prod2016)

#We also create a base map that will be used in all the following examples

library(leaflet)

tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"

basemap <- leaflet(width = "100%", height = "400px") %>%
  addTiles(tilesURL)

#We now add to the base map a pie chart for each region that represents the share of renewable energies. We also change the width of the pie charts so their area is proportional to the total production of the corresponding region.

colors <- c("#4fc13c", "#cccccc")

basemap %>%
  addMinicharts(
    prod2016$lng, prod2016$lat,
    type = "pie",
    chartdata = prod2016[, c("renewable", "non_renewable")], 
    colorPalette = colors, 
    width = 60 * sqrt(prod2016$total) / sqrt(max(prod2016$total)), transitionTime = 0
  )

# Now let’s represent the different types of renewable production using bar charts.

renewable2016 <- prod2016 %>% select(hydraulic, solar, wind)
colors <- c("#3093e5", "#fcba50", "#a0d9e8")
basemap %>%
  addMinicharts(
    prod2016$lng, prod2016$lat,
    chartdata = renewable2016,
    colorPalette = colors,
    width = 45, height = 45
  )

#Animated maps

#Until now, we have only represented aggregated data but it would be nice to create a map that represents the evolution over time of some variables. It is actually easy with leaflet.minicharts. The first step is to construct a table containing longitude, lattitude, a time column and the variables we want to represent. The table eco2mix already has all these columns. We only need to filter the rows containing data for the entire country.

prodRegions <- eco2mix %>% filter(area != "France")

#Now we can create our animated map by using the argument “time”:
  
  basemap %>% 
  addMinicharts(
    prodRegions$lng, prodRegions$lat, 
    chartdata = prodRegions[, c("hydraulic", "solar", "wind")],
    time = prodRegions$month,
    colorPalette = colors,
    width = 45, height = 45
  )
  
#  Represent flows
  
#  Since version 0.2, leaflet.minicharts has also functions to represent flows between points and their evolution. To illustrate this, let’s represent the evolution of electricity exchanges between France and Neighboring countries.
  
#  To do that, we use function addFlows. It requires coordinates of two points for each flow and the value of the flow. Other arguments are similar to addMinicharts.
  
  data("eco2mixBalance")
  bal <- eco2mixBalance
  basemap %>%
    addFlows(
      bal$lng0, bal$lat0, bal$lng1, bal$lat1,
      flow = bal$balance,
      time = bal$month
    )