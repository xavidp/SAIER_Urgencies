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
#data("eco2mix")
#head(eco2mix)

# -----------
# CUESB Data
# -----------
my_file <- file.path("K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències\ CUESB", "0 Base de dades_v10.xlsx")
# Read From xlsx sheet
# ..............................
# Option 1: readxl package
# ..............................
# From http://www.sthda.com/english/wiki/reading-data-from-excel-files-xls-xlsx-into-r
# The readxl package, developed by Hadley Wickham, can be used to easily import Excel files (xls|xlsx) into R without any external dependencies.
if (!require("readxl")) install.packages("readxl")
library("readxl")
# The readxl package comes with the function read_excel() to read xls and xlsx files. 
# xls files
#my_data <- read_excel("my_file.xls")
# xlsx files
#my_data <- read_excel("my_file.xlsx")

#Specify sheet with a number or name
# Specify sheet by its name
my_data <- read_excel(my_file, sheet = "Dades")
# Specify sheet by its index
#my_data <- read_excel("my_file.xlsx", sheet = 2)
head(my_data)
colnames(my_data)


geodata <- read_excel(my_file, sheet = "PaisesContinentes")

# Summarise data based on Country of origin
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)

# Select columns of interest
my_data2 <- my_data %>%
  # filter(grepl("EUROPA", ContinentNacion.)) %>%
  select(-Cognoms,
         -Nom,
         -Expedient,
         -ComunicacioDerivacio,
         -Nacionalitat, 
         -ContinentNacio,
         -LlocProcedencia, 
         -ContinentProced,
         -DetallObservacions,
         -AlertaMaltractament,
         -`Alerta salut`, 
         -OrientacioContinuitat
  ) %>%
  #    group_by(Nacionalitat_Angles) %>%
  #    summarise_all(sum) %>%
  ungroup()

head(my_data2)

# 
#  my_data3 <- my_data %>%
my_data3 <- add_count(my_data, NacionalitatAngles, wt = NULL, sort = TRUE)
head(my_data3[25:29])
colnames(my_data3)
my_data3

#my_data4 <- count(my_data, NacionalitatAngles, HomeDona, wt = NULL, sort = FALSE)
# We get a table data frame such as:
# # A tibble: 94 x 3
# NacionalitatAngles HomeDona     n
# <chr>    <chr> <int>
#   1        Afghanistan        D     1
# 2        Afghanistan        H    14
# 3        Afghanistan     <NA>     5
# 4            Albania        D     2
# 5            Albania        H     3
# 6            Algeria        D     2
# 7            Algeria        H     6
# 8          Argentina        D     1
# 9          Argentina        H     1
# 10            Armenia        H     2
# # ... with 84 more rows

my_data4 <- count(my_data, NacionalitatAngles, MesDerivacioSAIER, Edat, HomeDona, wt = NULL, sort = FALSE)
# # A tibble: 346 x 5
# NacionalitatAngles MesDerivacioSAIER  Edat HomeDona     n
# <chr>             <chr> <chr>    <chr> <int>
#   1        Afghanistan           2017-02 adult        D     1
# 2        Afghanistan           2017-02 adult        H     2
# 3        Afghanistan           2017-02 menor        H     1
# 4        Afghanistan           2017-03 adult        H     4
# 5        Afghanistan           2017-04 adult        H     1
# 6        Afghanistan           2017-05 adult        H     1
# 7        Afghanistan           2017-08 adult        H     3
# 8        Afghanistan           2017-08 adult     <NA>     4
# 9        Afghanistan           2017-08 menor     <NA>     1
# 10        Afghanistan           2017-09 adult        H     2

colnames(my_data4)
my_data4$NacionalitatAngles <- apply(my_data4, 2, toupper)
head(my_data4)
dim(my_data4)

# my_data2b <- my_data2 %>%
#   mutate(month = format(DataDerivacioSAIER, "%Y-%m")) %>%
#   group_by(month, HomeDona) %>%
#   select(NacionalitatAngles,
#          NMembresNucli,
#          ProcedenciaAngles) %>%
#   summarise(n = n())

#colnames(my_data2b)

#colnames(geodata)[7] <- "NacionalitatAngles"
colnames(geodata)
head(geodata)
dim(geodata)

# Add coordinates to the countries from the Dades sheet, using left_join
my_data5 <- my_data4 %>% left_join(geodata, by = c("NacionalitatAngles" = "PaisAngles"))

## Add coordinates to the countries from the Dades sheet using standard merge function
#my_data4 <- merge(x=my_data4, y=geodata, by = "NacionalitatAngles")
#head(my_data4)
#colnames(my_data4)

my_data5b <- my_data5 %>%
  # filter(grepl("EUROPA", ContinentNacion.)) %>%
  select(NacionalitatAngles,
         MesDerivacioSAIER,
         Edat,
         HomeDona,
         n,
         lon,
         lat
  ) %>%
  #    group_by(Nacionalitat_Angles) %>%
  #    summarise_all(sum) %>%
  ungroup()

head(my_data5b)


# ---
# Renewable productions in 2016
#library(dplyr)

# prod2016 <- eco2mix %>%
#   mutate(
#     renewable = bioenergy + solar + wind + hydraulic,
#     non_renewable = total - bioenergy - solar - wind - hydraulic
#   ) %>%
#   filter(grepl("2016", month) & area != "France") %>%
#   select(-month) %>%
#   group_by(area, lat, lng) %>%
#   summarise_all(sum) %>%
#   ungroup()
# 
# head(prod2016)
# head(my_data)

# Desactivat per que només cal 1 vegada
# ------
# Get coordinates for the capital of a country
# get cities latitude/longitude - kindly provided by google:
# if (!require("ggmap")) install.packages("ggmap")
# library(ggmap)
# all_cities <- read_excel(my_file, sheet = "PaisesContinentes")
# head(all_cities)
# all_geocodes <- geocode(as.character(all_cities$CAPITAL))
# all_cities2 <- data.frame(all_cities, all_geocodes)
# head(all_cities2)  
#
# The other coordinates not provided by ggmap were obtained by hand through 
# https://www.latlong.net/

# Save this precious set of coordinates for all contry capital into a new excel file, just in case
#library(xlsx) #load the package
#my_file2 <- file.path("K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències\ CUESB", "all_cities2.xlsx")
#write.xlsx(x = all_cities2, file = my_file2,
#           sheetName = "all_data", row.names = FALSE)
#workbook.sheets %>% workbook.test %>% addDataFrame(x = sample.dataframe, sheet = workbook.test,
#                         row.names = FALSE, startColumn = 4) # write data to sheet starting on line 1, column 4
#saveWorkbook(workbook.sheets, "test.excelfile.xlsx") # and of course you need to save it.
# ------

#my_data2 <- data.frame(my_data[,1:2], my_geocodes)

# ------
#We also create a base map that will be used in all the following examples

# library(leaflet)
# 
# tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
# 
# basemap <- leaflet(width = "100%", height = "400px") %>%
#   addTiles(tilesURL)
# 
# #We now add to the base map a pie chart for each region that represents the share of renewable energies. We also change the width of the pie charts so their area is proportional to the total production of the corresponding region.
# 
# colors <- c("#4fc13c", "#cccccc")
# 
# basemap %>%
#   addMinicharts(
#     prod2016$lng, prod2016$lat,
#     type = "pie",
#     chartdata = prod2016[, c("renewable", "non_renewable")], 
#     colorPalette = colors, 
#     width = 60 * sqrt(prod2016$total) / sqrt(max(prod2016$total)), transitionTime = 0
#   )
# 
# # Now let’s represent the different types of renewable production using bar charts.
# 
# renewable2016 <- prod2016 %>% select(hydraulic, solar, wind)
# colors <- c("#3093e5", "#fcba50", "#a0d9e8")
# basemap %>%
#   addMinicharts(
#     prod2016$lng, prod2016$lat,
#     chartdata = renewable2016,
#     colorPalette = colors,
#     width = 45, height = 45
#   )
# 
# #Animated maps
# 
# #Until now, we have only represented aggregated data but it would be nice to create a map that represents the evolution over time of some variables. It is actually easy with leaflet.minicharts. The first step is to construct a table containing longitude, lattitude, a time column and the variables we want to represent. The table eco2mix already has all these columns. We only need to filter the rows containing data for the entire country.
# 
# prodRegions <- eco2mix %>% filter(area != "France")
# 
# #Now we can create our animated map by using the argument “time”:
#   
#   basemap %>% 
#   addMinicharts(
#     prodRegions$lng, prodRegions$lat, 
#     chartdata = prodRegions[, c("hydraulic", "solar", "wind")],
#     time = prodRegions$month,
#     colorPalette = colors,
#     width = 45, height = 45
#   )
#   
# #  Represent flows
#   
# #  Since version 0.2, leaflet.minicharts has also functions to represent flows between points and their evolution. To illustrate this, let’s represent the evolution of electricity exchanges between France and Neighboring countries.
#   
# #  To do that, we use function addFlows. It requires coordinates of two points for each flow and the value of the flow. Other arguments are similar to addMinicharts.
#   
#   data("eco2mixBalance")
#   bal <- eco2mixBalance
#   basemap %>%
#     addFlows(
#       bal$lng0, bal$lat0, bal$lng1, bal$lat1,
#       flow = bal$balance,
#       time = bal$month
#     )
#   

#------------------------------------------
# Test Leaflet minicharts with CUESB data
#------------------------------------------
  library(leaflet)
  
  tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
  
  basemap <- leaflet(width = "100%", height = "400px") %>%
    addTiles(tilesURL)
  
  
  # Map Gender of immigrants in pie charts over the world map and separated by month
  # -------------------------------------------------------------
  my_data5c <- tidyr::spread(my_data5b, HomeDona, n)
  colnames(my_data5c)[8] <- "Desconegut"

  #We now add to the base map a pie chart for each country of origin
  #  colors <- c("#4fc13c", "lightyellow", "#cccccc")
  colors <- c("pink", "lightblue", "lightyellow")
  
  basemap %>%
    addMinicharts(
      my_data5c$lon, my_data5c$lat,
      type = "pie",
      chartdata = my_data5c[, c("D", "H", "Desconegut")], 
      fillColor = "white",
      colorPalette = colors, 
      time = my_data5c$MesDerivacioSAIER,
      transitionTime = 0,
      legend=TRUE,
      legendPosition = "topright"
    )
  
  # Map Gender of immigrants in pie charts over the world map and integrated overtime
  # -------------------------------------------------------------
  my_data5d <- count(my_data, NacionalitatAngles, HomeDona, wt = NULL, sort = FALSE)
  my_data5d <- tidyr::spread(my_data5d, HomeDona, n)
  colnames(my_data5d)[4] <- "Desconegut"
  my_data5d$NacionalitatAngles <- apply(my_data5d, 2, toupper)
  # Add coordinates to the countries from the Dades sheet, using left_join
  my_data5e <- my_data5d %>% left_join(geodata, by = c("NacionalitatAngles" = "PaisAngles"))
  my_data5e <- my_data5e %>%
    # filter(grepl("EUROPA", ContinentNacion.)) %>%
    select(NacionalitatAngles,
           D,
           H,
           Desconegut,
           lon,
           lat
    ) %>%
    #    group_by(Nacionalitat_Angles) %>%
    #    summarise_all(sum) %>%
    ungroup()
  
  head(my_data5e)
  
  #We now add to the base map a pie chart for each country of origin
  #  colors <- c("#4fc13c", "lightyellow", "#cccccc")
  colors <- c("pink", "lightblue", "lightyellow")
  
  basemap %>%
    addMinicharts(
      my_data5e$lon, my_data5e$lat,
      type = "pie",
      chartdata = my_data5e[, c("D", "H", "Desconegut")], 
      fillColor = "white",
      colorPalette = colors, 
      transitionTime = 0,
      legend=TRUE,
      legendPosition = "topright"
    )

  # Map Age group of immigrants in pie charts over the world map
  # -------------------------------------------------------------
  my_data6 <- count(my_data, NacionalitatAngles, Edat, wt = NULL, sort = FALSE)
  my_data6b <- tidyr::spread(my_data6, Edat, n)
  colnames(my_data6b)[4] <- "desconegut"
  my_data6b$NacionalitatAngles <- apply(my_data6b, 2, toupper)
  # Add coordinates to the countries from the Dades sheet, using left_join
  my_data6c <- my_data6b %>% left_join(geodata, by = c("NacionalitatAngles" = "PaisAngles"))
  
  my_data6d <- my_data6c %>%
    # filter(grepl("EUROPA", ContinentNacion.)) %>%
    select(NacionalitatAngles,
           adult,
           menor,
           desconegut,
           lon,
           lat
    ) %>%
    #    group_by(Nacionalitat_Angles) %>%
    #    summarise_all(sum) %>%
    ungroup()
  
  head(my_data6d)
  
  colors <- c("green", "lightgreen", "lightyellow")
  
  basemap %>%
    addMinicharts(
      my_data6d$lon, my_data6d$lat,
      type = "pie",
      chartdata = my_data6d[, c("adult", "menor", "desconegut")], 
      fillColor = "white",
      colorPalette = colors, 
      transitionTime = 0,
      legend=TRUE,
      legendPosition = "topright"
    )
  
  
  # Represent also flows
  # -----------------------
  # #  Represent flows
  #   
  # #  Since version 0.2, leaflet.minicharts has also functions to represent flows between points and their evolution. To illustrate this, let’s represent the evolution of electricity exchanges between France and Neighboring countries.
  #   
  # #  To do that, we use function addFlows. It requires coordinates of two points for each flow and the value of the flow. Other arguments are similar to addMinicharts.
  #   
    # data("eco2mixBalance")
    # bal <- eco2mixBalance
    # head(bal)

    # Represent flows with time info
    # ---------------------------------------------------------------
    my_data7 <- my_data %>% 
          count(NacionalitatAngles, ProcedenciaAngles, MesDerivacioSAIER, wt = NULL, sort = FALSE) %>%
          filter(!is.na(NacionalitatAngles) & !is.na(ProcedenciaAngles))
            
    
     my_data7$ProcedenciaAngles <- apply(matrix(my_data7$ProcedenciaAngles), 2, toupper)
     my_data7$NacionalitatAngles <- apply(matrix(my_data7$NacionalitatAngles), 2, toupper)
     # Add coordinates to the countries from the Dades sheet, using left_join
     my_data7b <- my_data7 %>% left_join(geodata, by = c("NacionalitatAngles" = "PaisAngles"))
     
     my_data7b <- my_data7b %>%
       # filter(grepl("EUROPA", ContinentNacion.)) %>%
       select(NacionalitatAngles, 
              ProcedenciaAngles,
              MesDerivacioSAIER,
              n,
              lon,
              lat
       ) %>%
       rename(lon0 = lon) %>%
       rename(lat0 = lat) %>%
       #    group_by(Nacionalitat_Angles) %>%
       #    summarise_all(sum) %>%
       ungroup()
     
     table(my_data7b$NacionalitatAngles)
     table(my_data7b$ProcedenciaAngles)

     my_data7c <- my_data7b %>% left_join(geodata, by = c("ProcedenciaAngles" = "PaisAngles"))
     my_data7c <- my_data7c %>%
       # filter(grepl("EUROPA", ContinentNacion.)) %>%
       select(NacionalitatAngles, 
              ProcedenciaAngles,
              MesDerivacioSAIER,
              n,
              lon0,
              lat0,
              lon,
              lat
       ) %>%
       rename(lon1 = lon) %>%
       rename(lat1 = lat) %>%
       #    group_by(Nacionalitat_Angles) %>%
       #    summarise_all(sum) %>%
       ungroup()
     
     head(my_data7c)
     dim(my_data7c)
     
     # Afegir les columnes de latitud i longitud de Barcelona com a destinació: lat1 lon1, per a grafic de fluxes de més avall
     bcn_lat <- rep(41.385064, dim(my_data7c)[1])
     bcn_lon <- rep(2.173403, dim(my_data7c)[1])
     
     bcn_loc <- data.frame(bcn_lat, bcn_lon)
     my_data7c <- bind_cols(my_data7c, bcn_loc)

     # I comment out this section (below) since the animation of the flows doesn't get updated properly due to some unknown reason
     # --------------------
       # basemap %>%
       #   addFlows(
       #     my_data7c$lon0, my_data7c$lat0, my_data7c$lon1, my_data7c$lat1,
       #     flow = my_data7c$n,
       #     time = my_data7c$MesDerivacioSAIER
       #   )

       
     # Represent flows with no time data, but flows aggregated over time per country
     # ---------------------------------------------------------------
     my_data7d <- my_data7c %>%
       filter(!is.na(lat0) & !is.na(lat1)) %>%
       select(-MesDerivacioSAIER, -bcn_lat, -bcn_lon) %>%
       group_by(NacionalitatAngles, ProcedenciaAngles, lat0, lon0, lat1, lon1) %>%
       summarise_all(sum) %>%
       ungroup()
       
     #filter(my_data7c, NacionalitatAngles != ProcedenciaAngles)
            
     basemap %>%
       addFlows(
         lng0 = my_data7d$lon0, 
         lat0 = my_data7d$lat0, 
         lng1 = my_data7d$lon1,
         lat1 = my_data7d$lat1,
         color = "blue",
         flow = my_data7d$n,
         maxFlow = max(my_data7d$n),
         minThickness = 2
       )
     #my_data7d <- count(my_data7c, ProcedenciaAngles, lon, lat, bcn_lon, bcn_lat, wt = NULL, sort = FALSE)
     leaflet() %>% addTiles() %>%
       addFlows(0.5, 0.2, 1.5, 1.2, flow = 10)
     
     basemap %>%
       addFlows(69.2074860, 34.5553494, 2.173403, 41.385064, flow = 10)
     
     my_data7d$lon[1]
     my_data7d$lat[1]
     my_data7d$bcn_lon[1]
     my_data7d$bcn_lat[1]
     my_data7d$n[1]
     
# -----------------------------------  
# Plot Map Using rworldmap
# Derived from: https://blog.learningtree.com/how-to-display-data-on-a-world-map-in-r/
  if (!require("rworldmap")) install.packages("rworldmap")
  library(rworldmap)
#getwd()  
#  ls()
#  population_records <- readLines(file.path(getwd(), "API_SP.POP.TOTL_DS2_en_csv_v2.csv"))[-(1:4)]
#  population_data <- read.csv(text=population_records, header = TRUE)
#  head(population_data)
  
#  population_data$Growth.5.Year <- 
#    ((population_data$X2014 - population_data$X2009) / population_data$X2014) * 100

#  mapped_data <- joinCountryData2Map(population_data, joinCode = "ISO3", 
#                                     nameJoinColumn = "Country.Code")
  #?joinCountryData2Map
  
 
  # let's prepare a geospatial data frame for the data to be plotted later on
  my_mapped_data <- joinCountryData2Map(my_data, joinCode = "NAME", 
                                     nameJoinColumn = "NacionalitatAngles")
  
#  my_mapped_data4 <- joinCountryData2Map(my_data4, joinCode = "NAME", 
#                                        nameJoinColumn = "NacionalitatAngles")

    #head(my_mapped_data)
  # joinCode = "ISO3" tells rworldmap to join the data using ISO 3166 codes.
  # 
  # joinCountryData2Map will report that it was unable to map some codes, but this doesn’t matter for our purposes.
  # 
  # We can now display the mapped data.
  # 
  par(mai=c(0,0,0.2,0),xaxs="i",yaxs="i")
#  mapCountryData(mapped_data, nameColumnToPlot = "Growth.5.Year")
  colnames(my_data)
  #str(my_mapped_data)
  my_mapped_data$NMembresNucli <- as.numeric(my_mapped_data$NMembresNucli)
  mapCountryData(my_mapped_data, 
                 nameColumnToPlot = "NMembresNucli", 
                 catMethod="pretty",
                 colourPalette="heat", 
                 mapTitle = "columnName", 
                 oceanCol = "lightblue",
                 missingCountryCol = "white")
  #?mapCountryData
  head(my_data)
  summary(my_data$NMembresNucli)
  table(my_data$NMembresNucli)
  
  my_mapped_data4
  
  mapCountryData(my_mapped_data4, 
                 catMethod="pretty",
                 colourPalette="heat", 
                 mapTitle = "columnName", 
                 oceanCol = "lightblue",
                 missingCountryCol = "white")
  # 
  # The par command only needs to be performed once in the session and just makes sure that all the available space in the window is used to display the map.
  
  # ---------------------------------------------------------
  # Nacionalitats SAIER per anys
  # ---------------------------------------------------------
  # Dades a: K:\QUOTA\DIMM_COMU\Maria\NACIONALITATS REFUGI_tancament 2015-2016 a juny 2016-2017.xlsx > Full1 
  #
  # Full1 	CATEGORIA 	a des. 2015 	a des. 2016 	ANY 2016 vs ANY 2015 	% creix. Anual
  # AFGANISTAN 	ÀSIA MERIDIONAL 	17 	35 	18 	51,43%
  # ALBANIA 	EUROPA ORIENTAL 	8 	17 	9 	52,94% 
  # ...
  my_file2 <- file.path("K:\\QUOTA\\DIMM_COMU\\Maria", "NACIONALITATS REFUGI_tancament 2015-2016 a juny 2016-2017_v02.xlsx")
  if (!require("readxl")) install.packages("readxl")
  library("readxl")
  my_data2 <- read_excel(my_file2, sheet = "Full1", range="A5:AJ125", na="NA")
  head(my_data2)
  colnames(my_data2)
  
  # libraries
  if (!require("dplyr")) install.packages("dplyr")
  library(dplyr)
  if (!require("treemap")) install.packages("treemap")
  library(treemap)
  if (!require("devtools")) install.packages("devtools")
  library(devtools)
  if (!require("d3treeR")) devtools::install_github("timelyportfolio/d3treeR")
  library(d3treeR)
  
  #md2 <- count(my_data2, CATEGORIA, NACIONALITAT, wt = NULL, sort = FALSE)
  md2 <- my_data2
  # basic treemaps
  p2015=treemap(md2,
            index=c("CATEGORIA","NACIONALITAT"),
            vSize="a des. 2015",
            type="index",
            title="Nacionalitats d'Usuaris al SAIER 2015",
            overlap.labels=1,
            force.print.labels=TRUE,
            aspRatio=2,
            align.labels=c("center", "center")
  )            
  p2016=treemap(md2,
                index=c("CATEGORIA","NACIONALITAT"),
                vSize="a des. 2016",
                type="index",
                title="Nacionalitats d'Usuaris al SAIER 2016",
                overlap.labels=1,
                force.print.labels=TRUE,
                aspRatio=2.5,
                bg.labels=75,
                align.labels=c("center", "center")
  )            
  md2$"% creix. Anual"
  md2$"% 2016 vs 2015"
  md2$NACIONALITAT
  length(md2$NACIONALITAT)
  p2016b=treemap(md2,
                index=c("CATEGORIA","NACIONALITAT"),
                vSize="a des. 2016",
                title="Nacionalitats d'Usuaris al SAIER 2016",
                title.legend="Mida proporcional al nombre; color segons % de canvi anual",
#                type="dens",
#                vColor="% 2016 vs 2015",
                type="comp",
                vColor="a des. 2015",
                palette="RdYlBu",
                overlap.labels=1,
                aspRatio=2.5,
                force.print.labels=TRUE,
                align.labels=c("center", "center")
  ) 
  # To see all possible easy color palettes, run:
  #RColorBrewer::display.brewer.all()
  
  # make it interactive ("rootname" becomes the title of the plot):
  inter2015=d3tree2( p2015 ,  rootname = "Nacionalitats Usuaris SAIER - 2015" )
  inter2015
  inter2016=d3tree2( p2016 ,  rootname = "Nacionalitats Usuaris SAIER - 2016" )
  inter2016
  inter2016b=d3tree2( p2016b ,  rootname = "Nacionalitats Usuaris SAIER - 2016 vs 2015" )
  inter2016b
  
  
  
  # World Charts using Plotly
  # ----------------------------------------
  # https://plot.ly/r/choropleth-maps/
  # https://plot.ly/r/bubble-maps/
  # https://plot.ly/r/lines-on-maps/
  #
  if (!require("plotly")) install.packages("plotly")
  library(plotly)
  packageVersion('plotly')
  
  # For a list of projections for maps, see:
  # https://plot.ly/r/reference/#layout-geo-projection
    
  #df <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2014_world_gdp_with_codes.csv')
  my_file3 <- file.path("K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències\ CUESB", "0 Base de dades_v04.xlsx")
  
  # Example of Choropleth World Map
  #----------------------------------
  df <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2014_world_gdp_with_codes.csv')
  
  # light grey boundaries
  l <- list(color = toRGB("grey"), width = 0.5)
  
  # specify map projection/options
  g <- list(
    showframe = FALSE,
    showcoastlines = FALSE,
    projection = list(type = 'natural earth') 
  )
  
  p <- plot_geo(df) %>%
    add_trace(
      z = ~GDP..BILLIONS., color = ~GDP..BILLIONS., colors = 'Blues',
      text = ~COUNTRY, locations = ~CODE, marker = list(line = l)
    ) %>%
    colorbar(title = 'GDP Billions US$', tickprefix = '$') %>%
    layout(
      title = '2014 Global GDP<br>Source:<a href="https://www.cia.gov/library/publications/the-world-factbook/fields/2195.html">CIA World Factbook</a>',
      geo = g
    )
  p
  
  # It doesn't plot the map in AAI's computer (AjBCN) I dunno why :-(  - 2/2/2018
  
  
  # Keep an eye on d3treemap (based on d3.js and treemap R package)
  # --------------------------
  # https://github.com/timelyportfolio/d3treeR
  # http://www.buildingwidgets.com/blog/2015/7/17/week-28-d3treer
  # http://www.buildingwidgets.com/blog/2015/7/22/week-29-d3treer-v2