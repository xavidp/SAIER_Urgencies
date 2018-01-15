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
my_file <- file.path("K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències\ CUESB", "0 Base de dades_v03.xlsx")
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
         -OrientacioContinuitat,
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

colnames(geodata)[7] <- "NacionalitatAngles"
colnames(geodata)
head(geodata)
dim(geodata)

# Add coordinates to the countries from the Dades sheet, using left_join
my_data5 <- my_data4 %>% left_join(geodata)

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
         lat,
  ) %>%
  #    group_by(Nacionalitat_Angles) %>%
  #    summarise_all(sum) %>%
  ungroup()

head(my_data5b)

# ..............................
# Option 2: xlsx package
# ..............................
# From http://www.sthda.com/english/wiki/reading-data-from-excel-files-xls-xlsx-into-r
# The xlsx package, a java-based solution, is one of the powerful R packages to read, write and format Excel files.
#if (!require("xlsx")) install.packages("xlsx")
#library("xlsx")
# There are two main functions in xlsx package for reading both xls and xlsx Excel files: read.xlsx() and read.xlsx2() [faster on big files compared to read.xlsx function].
# The simplified formats are:
#read.xlsx(file, sheetIndex, header=TRUE)
#read.xlsx2(file, sheetIndex, header=TRUE)


#file: file path
#sheetIndex: the index of the sheet to be read
#header: a logical value. If TRUE, the first row is used as column names.

# ..............................
# option3 - read.xlsx From openxlsx v4.0.17
# ..............................
#https://www.rdocumentation.org/packages/openxlsx/versions/4.0.17/topics/read.xlsx
#Read from an Excel file or Workbook object
# Read data from an Excel file or Workbook object into a data.frame. Through the use of
# 'Rcpp', read/write times are comparable to the 'xlsx' and 'XLConnect' packages
# with the added benefit of removing the dependency on Java
#
#if (!require("openxlsx")) install.packages("openxlsx")
#
#read.xlsx(xlsxFile, sheet = 1, startRow = 1, colNames = TRUE,
#          rowNames = FALSE, detectDates = FALSE, skipEmptyRows = TRUE,
#          skipEmptyCols = TRUE, rows = NULL, cols = NULL, check.names = FALSE,
#          namedRegion = NULL, na.strings = "NA", fillMergedCells = FALSE)



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
  
  my_data5c <- tidyr::spread(my_data5b, HomeDona, n)
  colnames(my_data5c)[8] <- "Desconegut"

  #We now add to the base map a pie chart for each country of origin
  #  colors <- c("#4fc13c", "lightyellow", "#cccccc")
  colors <- c("pink", "lightblue", "#cccccc")
  
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
  
  
  my_data6 <- count(my_data, NacionalitatAngles, Edat, wt = NULL, sort = FALSE)
  my_data6b <- tidyr::spread(my_data6, Edat, n)
  colnames(my_data6b)[4] <- "desconegut"
  my_data6b$NacionalitatAngles <- apply(my_data6b, 2, toupper)
  # Add coordinates to the countries from the Dades sheet, using left_join
  my_data6c <- my_data6b %>% left_join(geodata)
  
  my_data6d <- my_data6c %>%
    # filter(grepl("EUROPA", ContinentNacion.)) %>%
    select(NacionalitatAngles,
           adult,
           menor,
           desconegut,
           lon,
           lat,
    ) %>%
    #    group_by(Nacionalitat_Angles) %>%
    #    summarise_all(sum) %>%
    ungroup()
  
  head(my_data6d)
  
  colors <- c("blue", "lightblue", "#cccccc")
  
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
  
  