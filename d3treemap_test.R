# From https://www.r-graph-gallery.com/237-interactive-treemap/



# library
if (!require("treemap")) install.packages("treemap")
library(treemap)
if (!require("devtools")) install.packages("devtools")
library(devtools)
if (!require("d3treeR")) devtools::install_github("timelyportfolio/d3treeR")
library(d3treeR)

# dataset
group=c(rep("group-1",4),rep("group-2",2),rep("group-3",3))
subgroup=paste("subgroup" , c(1,2,3,4,1,2,1,2,3), sep="-")
value=c(13,5,22,12,11,7,3,1,23)
data=data.frame(group,subgroup,value)

# basic treemap
p=treemap(data,
          index=c("group","subgroup"),
          vSize="value",
          type="index"
)            

# make it interactive ("rootname" becomes the title of the plot):
inter=d3tree2( p ,  rootname = "General" )

inter

# Do with CUESB data
my_file <- file.path("K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències\ CUESB", "0 Base de dades_v04.xlsx")
if (!require("readxl")) install.packages("readxl")
library("readxl")
my_data <- read_excel(my_file, sheet = "Dades")
# Specify sheet by its index
#my_data <- read_excel("my_file.xlsx", sheet = 2)
head(my_data)
colnames(my_data)

if (!require("dplyr")) install.packages("dplyr")
library(dplyr)
md <- count(my_data, ContinentNacio, Nacionalitat, wt = NULL, sort = FALSE)
# basic treemap
p=treemap(md,
          index=c("ContinentNacio","Nacionalitat"),
          vSize="n",
          type="index"
)            

# make it interactive ("rootname" becomes the title of the plot):
inter=d3tree2( p ,  rootname = "Nacionalitats Derivacions CUESB a SAIER - 2017" )
inter
