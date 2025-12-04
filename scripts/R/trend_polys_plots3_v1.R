#=================================================================================
# Spatio-temporal Pattern Analysis - Create Plots 3
#=================================================================================
# 2025-12-02
# Peter R.

#  - Notes: 
#   - This code is part of my Thesis Chapter 4
#   - Aim: Create plots that resemble those produced by stampr package.
#   - The code is for running locally (not DRAC)
#   - The main strategy:  Trend raster polygons --> stamp
#   - There are 8 different types of trend classes
#   - We are looking at 4 periods: 2003-2007, 2008-2012, 2013-2017 & 2018-2022
#   - Some trend classes are not available for all periods. Mostly only classes 1 & 2 when using 5-year periods.
#   - Note that I could not get stampr to work for the whole study area. Hence, I had to recreate some of the pacakage's functionality using Postgis.
#   - Here I try to recreate some stampr objects to re-use some of the plot code I already developed for the pilot study area.
#   - Here I plot change polygons (three levels: p1 vs p2, p2 vs. p3, p3 vs. p4)
#   - I recreated the code below as I couldn't locate the original script
#   - This code creates side by side stamp event bar plots.
#   - For stamp events by protection status see: C:/Users/Peter R/github/forc_stamp/scripts/R/trend_polys_plots2_v2.R

#start.time <- Sys.time()
#start.time


#=================================
# Load libraries
# ================================

library(terra)
library(sf)
library(foreach)
library(doParallel)
library(DBI)
#library(dplyr)
#library(sqldf)
#library(raster)
#library(landscapemetrics)


#devtools::install_github("jedalong/stampr") # this loads version 0.3.1. This version uses sf
#library(stampr) # this loads version 0.2 which seems to work with spdep/sp

# for radar plots
# library(fmsb)
# library(scales)
# library(RColorBrewer)
# 
library(ggplot2)
library(tidyr)
# 
# library(plyr)




#=================================
# File paths and folders
# ================================

#setwd("C:/Users/Peter R/Documents/st_trends_for_c/algonquin")
setwd("C:/Users/Peter R/Documents/forc_stamp/") # local
#setwd("~/projects/def-mfortin/georod/scripts/github/forc_stpa") # drac

#dataf <- "~/projects/def-mfortin/georod/data/forc_stpa" # data folder


#infolder1 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h1yr/EVI_250m/bfast01/" # local
#infolder1 <- "~/forc_stpa/output1/change_poly"
infolder1 <- "C:/Users/Peter R/Documents/forc_stpa/drac/output1"
#infolder1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/output1/" # DRAC

infolder2 <- infolder1

#outf1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"
outf1 <- "C:/Users/Peter R/Documents/forc_stamp/output1/img/"
#outf1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/output1/"


# Study area bounding box
#shp1 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection
#shp1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/input1/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection # DRAC
#shp1 <- "~/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1.shp"
#shp2 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/study_area_subset_v3.shp" # EPSG:3347

shp1 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection # local

# protected area shp
#shp2 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/ver2/data/gis/shp/cpcad_dec2020_clipped2.shp"

# Forest & non-forest in study area crop raster (bigger extent than study area)

#shp4 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj_3978.shp"


# Database connection to Postgres

con1 <- DBI::dbConnect(RPostgres::Postgres(), dbname = "resnet1", host='localhost', port=5432, user=Sys.getenv("username"), password=Sys.getenv("pwd"))


#--------------------------------------------------
# Read data
#--------------------------------------------------

# For this plot data are read from the db not files

#files1 <- list.files(path=infolder1, recursive = TRUE, pattern = 'level2_v1\\.gpkg$', full.names=TRUE) # greening

#files1 <- files1[-grep("flag", files1, fixed=T)]

# Only choose files from a given trend type (e.g., greening)
#files1 <- files1[c(1,3,5,7)]  # Edit as needed 
#files1 <- files1[c(2,12,22,32)]  # Edit as needed 

# load polygons
# 
# polyL <- foreach (i=1:length(files1)) %do% {
#   
#   temp1 <- sf::st_read(files1[i])
#   #temp1$ID <- 1:nrow(temp1)
#   #sf::st_transform(temp1, crs = st_crs(3347)) # Why project?
#   
# }

#length(polyL)
#class(polyL[[1]])
#st_crs(polyL[[1]])


#-------------------------------------------------------
# Labels needed for files, folders, plots, etc.
#-------------------------------------------------------

# labels for plots
chPerLabs <- c("Period 1 vs. 2", "Period 2 vs. 3", "Period 3 vs. 4")

# labels for folder & files names
trendLabs <- c("greening", "browning")

trendChangeLabs <- c("cont", "disa", "expn", "genr", "stbl")

periodYrLabs <- c('2003-2007', '2008-2012', '2013-2017', '2018-2022')
periodYrLabs2 <- c('Period 1 vs. 2', 'Period 2 vs. 3', 'Period 3 vs. 4')
periodYrLabs3 <- c('1 vs. 2', '2 vs. 3', '3 vs. 4')

pgTabs <- c("evi_brown_ch1_level2_v1","evi_brown_ch2_level2_v1","evi_brown_ch3_level2_v1",
            "evi_green_ch1_level2_v1","evi_green_ch2_level2_v1","evi_green_ch3_level2_v1")

trendLabs <- c("greening", "browning")


#--------------------------------------------------
# Read tables found in Postgres 
#--------------------------------------------------
pgTabsL <- foreach(i=1:length(pgTabs)) %do% {
  
  temp1 <- st_read(con1, layer = pgTabs[i])
  st_crs(temp1) <- proj1
  st_transform(temp1, proj1)
  
}


chPoly <- foreach (i=1:length(pgTabsL), .combine = rbind) %do% {
  
  temp1 <- sf::st_transform(pgTabsL[[i]], 3347)

  temp1$trend <- substr(pgTabs[i] , start = 5, stop = 9) # extract trend name from files name
  
  temp1$change <- substr(pgTabs[i], start = 11, stop = 13) # extract change name from files name
  
  sum_area <- sum(st_area(temp1))/1e4


  
  foreach(j=1:length(trendChangeLabs), .combine=rbind) %do% {
    
    temp2 <- temp1[temp1$"level2"==trendChangeLabs[j], ]
    
    
    if (nrow(temp2)>0) { 
      
      
      sum_poly <- data.frame("number"=nrow(temp2), "area"= as.numeric(sum(sf::st_area(temp2)))/10000)
      
      sum_poly$"trend" <- unique(temp2$trend)
      sum_poly$"change" <- unique(temp2$change)
      sum_poly$"level2" <- unique(temp2$"level2") 
      sum_poly$percent <- (sum_poly$area/sum_area)*100
      sum_poly
      
    } else {
      
      sum_poly <- data.frame("number"=0, "area"=0, "trend"=unique(temp1$trend) , "change"=unique(temp1$change ), "level2"=trendChangeLabs[j], "percent"=0)
      
    }
    
    
  }
  
  
}


chPoly$periodYrLabs3 <- ifelse(chPoly$change=="ch1", periodYrLabs3[1], ifelse(chPoly$change=="ch2", periodYrLabs3[2], periodYrLabs3[3]) )
chPoly$trend <-  paste0(tools::toTitleCase(chPoly$trend), "ing")




# ------------------------------------------------------
# These plot shows greening and browning side by side
# ------------------------------------------------------

# Create plot, Number of polygons
png(file=paste0(outf1, "gr_br", "_npatches_global1", ".png"),
    units = "in",
    width = 6,
    height = 4.5, #3.5
    res = 300)

# Colour used in QGIS
# Use position=position_dodge()
ggplot(data=chPoly, aes(x=periodYrLabs3, y=number, fill=level2)) +
  geom_bar(stat="identity", position=position_dodge()) + ylab("Number of polygons") + xlab("Period comparison") + 
  scale_fill_manual(values=c("#f28304", "#cc0c24", "#305a02", "#7ee61c", "#181e1e")) +
  facet_grid(~ factor(trend, c("Browning", "Greening"))) + theme_bw() + theme(legend.position="bottom") + labs(fill = "Change type:")

dev.off()


# Create plot, area of polygons. This plot is not needed
# png(file=paste0(outf1, "gr_br", "_area_patches_global1", ".png"),
#     units = "in",
#     width = 6,
#     height = 4.5,
#     res = 300)
# 
# # Colour used in QGIS
# # Use position=position_dodge()
# ggplot(data=chPoly, aes(x=periodYrLabs3, y=area, fill=level2)) +
#   geom_bar(stat="identity", position=position_dodge()) + ylab("Area of polygons (ha)") + xlab("Period comparison") + 
#   scale_fill_manual(values=c("#f28304", "#cc0c24", "#305a02", "#7ee61c", "#181e1e")) +
#   facet_grid(~ factor(trend, c("Browning", "Greening"))) + theme_bw() + theme(legend.position="bottom") + labs(fill = "Change type:")
# 
# dev.off()

# Create plot, percent of polygons relative tu study area
png(file=paste0(outf1, "gr_br", "_per_area_patches_global1", ".png"),
    units = "in",
    width = 6,
    height = 4.5, #3.5
    res = 300)

# Colour used in QGIS
# Use position=position_dodge()
ggplot(data=chPoly, aes(x=periodYrLabs3, y=as.numeric(percent), fill=level2)) +
  geom_bar(stat="identity", position=position_dodge()) + ylab("Area event measure (%)") + xlab("Period comparison") + 
  scale_fill_manual(values=c("#f28304", "#cc0c24", "#305a02", "#7ee61c", "#181e1e")) +
  facet_grid(~ factor(trend, c("Browning", "Greening"))) + theme_bw() + theme(legend.position="bottom") + labs(fill = "Change type:")


dev.off()

