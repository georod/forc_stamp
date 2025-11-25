#=================================================================================
# Spatio-temporal Pattern Analysis - Create Plots 1
#=================================================================================
# 2025-01-27
# Peter R.

#  - Notes:
#   - This code is part of my Thesis Chapter 3
#   - Aim: Create plots that resemble those produced by stampr package.
#   - The code is for running locally (not DRAC)
#   - The main strategy:  Trend raster polygons --> stamp
#   - There are 8 different types of trend classes
#   - We are looking at 4 periods: 2003-2007, 2008-2012, 2013-2017 & 2018-2022
#   - Some trend classes are not available for all periods. Mostly only classes 1 & 2 when using 5-year periods.
#   - Note that I could not get stampr to work for the whole study area. Hence, I had to recreate some of the pacakage's functionality using Postgis.
#   - Here I try to recreate some stampr objects to re-use some of the plot code I already developed for the pilot study area.


#start.time <- Sys.time()
#start.time


#=================================
# Load libraries
# ================================

library(terra)
library(sf)
library(foreach)
library(doParallel)
#library(dplyr)
#library(sqldf)


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
setwd("C:/Users/Peter R/Documents/forc_stpa/") # local
#setwd("~/projects/def-mfortin/georod/scripts/github/forc_stpa") # drac

dataf <- "~/projects/def-mfortin/georod/data/forc_stpa" # data folder


#infolder1 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h1yr/EVI_250m/bfast01/" # local
infolder1 <- "C:/Users/Peter R/Documents/forc_stpa/drac/output1"
#infolder1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/output1/" # DRAC

#infolder2 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
#infolder2 <- "C:/Users/Peter R/Documents/forc_stpa/input1/"

infolder2 <- infolder1

# outf2 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
# outf3 <- "C:/Users/Peter R/Documents/forc_stpa/output1/gis/"
# outf4 <- "C:/Users/Peter R/Documents/forc_stpa/output1/data/"
# outf5 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"

outf1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"
#outf1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/output1/"


# Study area bounding box
shp1 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection
#shp1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/input1/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection # DRAC
#shp1 <- "~/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1.shp"
#shp2 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/study_area_subset_v3.shp" # EPSG:3347

#shp1 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection # local


#--------------------------------------------------
# Read data
#--------------------------------------------------

files1 <- list.files(path=infolder2, recursive = TRUE, pattern = 'type1_16d2\\.shp$', full.names=TRUE) # greening
files2 <- list.files(path=infolder2, recursive = TRUE, pattern = 'type2_16d2\\.shp$', full.names=TRUE) # browning

#files1 <- files1[-grep("flag", files1, fixed=T)]

# Only choose files from a given trend type (e.g., greening)
#files1 <- files1[c(1,3,5,7)]  # Edit as needed 
#files1 <- files1[c(2,12,22,32)]  # Edit as needed 

# load polygons
polyL <- list()

polyL <- foreach (i=1:length(files1)) %do% {
  
  temp1 <- sf::st_read(files1[i])
  #temp1$ID <- 1:nrow(temp1)
  #sf::st_transform(temp1, crs = st_crs(3347)) # Why project?
  
}

#length(polyL)
#class(polyL[[1]])
#st_crs(polyL[[1]])



# Browning
# load polygons
polyL <- list()

polyL <- foreach (i=1:length(files2)) %do% {
  
  temp1 <- sf::st_read(files2[i])
  #temp1$ID <- 1:nrow(temp1)
  #sf::st_transform(temp1, crs = st_crs(3347)) # Why project?
  
}


#========================================
# Parallel processing settings
#========================================

# Use the environment variable SLURM_CPUS_PER_TASK to set the number of cores.
# This is for SLURM. Replace SLURM_CPUS_PER_TASK by the proper variable for your system.
# Avoid manually setting a number of cores.
#ncores = Sys.getenv("NUMBER_OF_PROCESSORS") 
#ncores = detectCores()
#
#registerDoParallel(cores=ncores)# Shows the number of Parallel Workers to be used
#print(ncores) # this how many cores are available, and how many you have requested.
#getDoParWorkers()# you can compare with the number of actual workers


#-------------------------------------------------------
# Labels needed for files, folders, plots, etc.
#-------------------------------------------------------

# labels for plots
chPerLabs <- c("Period 1 vs. 2", "Period 2 vs. 3", "Period 3 vs. 4")

# labels for folder & files names
trendLabs <- c("greening", "browning")

periodYrLabs <- c('2003-2007', '2008-2012', '2013-2017', '2018-2022')
periodYrLabs2 <- c('Period 1 vs. 2', 'Period 2 vs. 3', 'Period 3 vs. 4')
periodYrLabs3 <- c('1 vs. 2', '2 vs. 3', '3 vs. 4')


#------------------------------------------------------
# Global change metrics
#------------------------------------------------------

globalP1 <- data.frame("nrow_t1"=nrow(polyL[[1]]), "nrow_t2"=nrow(polyL[[2]]), "area_t1"= sum(sf::st_area(polyL[[1]])), "area_t2"=sum(sf::st_area(polyL[[2]])))
globalP2 <- data.frame("nrow_t1"=nrow(polyL[[2]]), "nrow_t2"=nrow(polyL[[3]]), "area_t1"= sum(sf::st_area(polyL[[2]])), "area_t2"=sum(sf::st_area(polyL[[3]])))
globalP3 <- data.frame("nrow_t1"=nrow(polyL[[3]]), "nrow_t2"=nrow(polyL[[4]]), "area_t1"= sum(sf::st_area(polyL[[3]])), "area_t2"=sum(sf::st_area(polyL[[4]])))

globalAll <- rbind(globalP1,globalP2,globalP3) 
globalAll$NumRatio <- (globalAll$nrow_t1/globalAll$nrow_t2)          
globalAll$AreaRatio <- as.numeric(globalAll$area_t1/globalAll$area_t2)
globalAll$AvgAreaRatio <- as.numeric(globalAll$AreaRatio/globalAll$NumRatio)
globalAll$label <- c("1 vs. 2", "2 vs. 3", "3 vs. 4")



 # Better to run locally
 # make df long to use faceting
 globalAllLong <- gather(globalAll, key="measure", value="value", c("NumRatio","AreaRatio", "AvgAreaRatio"))

 globalAllLong$measure2 <- ifelse(globalAllLong$measure=="NumRatio", "Number", ifelse(globalAllLong$measure=="AreaRatio", "Area", "Avg. Area"))

 # Turn facet variable into fator to keep order
 globalAllLong$measure2 <- factor(globalAllLong$measure2, levels=c('Number','Area','Avg. Area'))
 
 

 
 # hex colours
 # brown: #b96216
 # green: #418a1c

 # Create plot, Greening
 png(file=paste0(outf1, trendLabs[1], "_global2", ".png"),
       units = "in",
       width = 6,
       height = 3.5,
       res = 300)

 # ggplot(globalAllLong, aes(x=label, y=value))+
 #   geom_bar(stat='identity', fill="forest green")+
 #   facet_wrap(~measure2)   + ylab("Ratio") + xlab("Period comparison, Greening")
 
 # Greening colour used in QGIS
 ggplot(globalAllLong, aes(x=label, y=value))+
   geom_bar(stat='identity', fill="#418a1c") +
   facet_wrap(~measure2)   + ylab("Ratio") + xlab("Period comparison, Greening") #+  theme_bw()

 dev.off()
 

 #------------------------------------------------------
 # Create plot, Browning
 png(file=paste0(outf1, trendLabs[2], "_global2", ".png"),
     units = "in",
     width = 6,
     height = 3.5,
     res = 300)
 
 # ggplot(globalAllLong, aes(x=label, y=value))+
 #   geom_bar(stat='identity', fill="forest green")+
 #   facet_wrap(~measure2)   + ylab("Ratio") + xlab("Period comparison, Greening")
 
 # Browning colour used in QGIS
 ggplot(globalAllLong, aes(x=label, y=value))+
   geom_bar(stat='identity', fill="#b96216") +
   facet_wrap(~measure2)   + ylab("Ratio") + xlab("Period comparison, Browning") #+  theme_bw()
 
 dev.off()
 
 
 #-------------------------------------------------------
 # Greening and browning side by side
 
 #proj1 <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs +type=crs" 
 #sf::st_area(st_transform(st_read(shp1), proj1))
 study_area <- as.numeric(sf::st_area(st_read(shp1)))/10000
 

 GrL1 <- foreach (i=1:length(files1), .combine = rbind) %do% {
   
   temp1 <- sf::st_read(files1[i])

   data.frame("number"=nrow(temp1), "area"= as.numeric(sum(sf::st_area(temp1)))/10000, "trend"="Greening", "period" = i)
   
 }
 
 
 BrL1 <- foreach (i=1:length(files2), .combine = rbind) %do% {
   
   temp1 <- sf::st_read(files2[i])

   data.frame("number"=nrow(temp1), "area"= as.numeric(sum(sf::st_area(temp1)))/10000, "trend"="Browning","period" = i)
   
 }
 

GrBrDf <- rbind(GrL1, BrL1)
GrBrDf$percent <- GrBrDf$area/study_area*100
GrBrDf$period <- as.factor(period)


 # ------------------------------------------------------
  # This plot shows greening and browning side by side
 
 # Create plot, Number of polygons
 png(file=paste0(outf1, "gr_br", "_npatches_global1", ".png"),
     units = "in",
     width = 6,
     height = 3.5,
     res = 300)
 
 # Colour used in QGIS
# Use position=position_dodge()
ggplot(data=GrBrDf, aes(x=period, y=number, fill=trend)) +
  geom_bar(stat="identity", position=position_dodge()) + ylab("Number of patches") + xlab("Period") + scale_fill_manual(values=c("#b96216", "#418a1c"))

 dev.off()
 
 
 # Create plot, area of polygons
 png(file=paste0(outf1, "gr_br", "_area_patches_global1", ".png"),
     units = "in",
     width = 6,
     height = 3.5,
     res = 300)
 
 # Colour used in QGIS
 # Use position=position_dodge()
 ggplot(data=GrBrDf, aes(x=period, y=area/100, fill=trend)) +
   geom_bar(stat="identity", position=position_dodge()) + ylab("Area of patches" ~(km^2)) + xlab("Period") + scale_fill_manual(values=c("#b96216", "#418a1c"))
 
 dev.off()
 
 # Create plot, percent of polygons relative tu study area
 png(file=paste0(outf1, "gr_br", "_per_area_patches_global1", ".png"),
     units = "in",
     width = 6,
     height = 3.5,
     res = 300)
 
 # Colour used in QGIS
 # Use position=position_dodge()
 ggplot(data=GrBrDf, aes(x=period, y=percent, fill=trend)) +
   geom_bar(stat="identity", position=position_dodge()) + ylab("Patch percent of study area") + xlab("Period") + scale_fill_manual(values=c("#b96216", "#418a1c"))
 
 dev.off()
