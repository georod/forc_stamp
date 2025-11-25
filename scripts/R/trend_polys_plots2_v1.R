#=================================================================================
# Spatio-temporal Pattern Analysis - Create Plots 2
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
#   - Here I plot change polygons (three levels: p1 vs p2, p2 vs. p3, p3 vs. p4)


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
setwd("C:/Users/Peter R/Documents/forc_stpa/") # local
#setwd("~/projects/def-mfortin/georod/scripts/github/forc_stpa") # drac

dataf <- "~/projects/def-mfortin/georod/data/forc_stpa" # data folder


#infolder1 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h1yr/EVI_250m/bfast01/" # local
infolder1 <- "~/forc_stpa/output1/change_poly"
#infolder1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/output1/" # DRAC

#infolder2 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
#infolder2 <- "C:/Users/Peter R/Documents/forc_stpa/input1/"


# outf2 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
# outf3 <- "C:/Users/Peter R/Documents/forc_stpa/output1/gis/"
# outf4 <- "C:/Users/Peter R/Documents/forc_stpa/output1/data/"
# outf5 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"

outf1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"
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

shp4 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj_3978.shp"

# Database connection to Postgres

con1 <- DBI::dbConnect(RPostgres::Postgres(), dbname = "resnet1", host='localhost', port=5432, user=Sys.getenv("username"), password=Sys.getenv("pwd"))


#--------------------------------------------------
# Read data
#--------------------------------------------------

# For this plot data are read from the db

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

trendChangeLabs <- c("cont", "disa", "expn", "genr", "stbl")

periodYrLabs <- c('2003-2007', '2008-2012', '2013-2017', '2018-2022')
periodYrLabs2 <- c('Period 1 vs. 2', 'Period 2 vs. 3', 'Period 3 vs. 4')
periodYrLabs3 <- c('1 vs. 2', '2 vs. 3', '3 vs. 4')


#------------------------------------------------------
# Global Level 2 change metrics
#------------------------------------------------------


proj1 <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs +type=crs" # sinusoidal projection
#sf::st_area(st_transform(st_read(shp1), proj1))
study_area <- as.numeric(sf::st_area(st_read(shp1)))/10000 ## box

forestAreaHa <- c(1324087) # in m2=13,240'868,400, in ha=1'324,087
proforestAreaHa <- c(220046.5)
nonproforestAreaHa <- c(1324087)


pgTabs <- c("evi_brown_ch1_level2_pro_v3","evi_brown_ch2_level2_pro_v3","evi_brown_ch3_level2_pro_v3",
            "evi_green_ch1_level2_pro_v3","evi_green_ch2_level2_pro_v3","evi_green_ch3_level2_pro_v3")

statusLab <- c("Non-protected", "Protected")
sum_area_for_status <- c( nonproforestAreaHa, proforestAreaHa)


# Read tables found in POstgres  
pgTabsL <- foreach(i=1:length(pgTabs)) %do% {
  
  temp1 <- st_read(con1, layer = pgTabs[i])
  st_crs(temp1) <- proj1
  st_transform(temp1, proj1)
  
}



chPoly <- foreach (i=1:length(pgTabsL), .combine = rbind) %do% {
  
  temp1 <- sf::st_transform(pgTabsL[[i]], 3347)
  # In Postgis script non-protected=0, protected=1. Below I recode this to 1 and 2 respectively. 
  # This way, I can use indeces more easily
  temp1$status <- temp1$status+1  
  
  temp1$trend <- substr(pgTabs[i] , start = 5, stop = 9) # extract trend name from files name
  
  temp1$change <- substr(pgTabs[i], start = 11, stop = 13) # extract change name from files name
  #sum_area <- forestAreaHa  # Change this to percent forest in study area
  #sum_area_proFor <- proforestAreaHa  # Change this to percent forest in study area
  #sum_area_nonproFor <- nonproforestAreaHa  # Change this to percent forest in study area
  

  
  foreach(j=1:length(trendChangeLabs), .combine=rbind) %do% {
    
    
    foreach(k=1:length(statusLab), .combine=rbind) %do%  { 
      
     
    temp2 <- temp1[temp1$"level2"==trendChangeLabs[j] & temp1$status==k, ]
    
    #temp3 <- temp1[temp1$"level2"==trendChangeLabs[j] & temp1$status==0, ]
    
  
    if (nrow(temp2)>0) { 
      
    
    sum_poly <- data.frame("number"=nrow(temp2), "area"= as.numeric(sum(sf::st_area(temp2)))/10000)
    
    sum_poly$"trend" <- unique(temp2$trend)
    sum_poly$"change" <- unique(temp2$change)
    sum_poly$"level2" <- unique(temp2$"level2") 
    #sum_poly$percent_for <- (sum_poly$area/sum_area)*100
    sum_poly$percent <- (sum_poly$area/sum_area_for_status[k])*100
    #sum_poly$avg_area <- sum_poly$area/sum_poly$number  # number of polygons no longer makes sense when dividing by protected status because of a given patch can span both protected and non-protected forest polygons
    sum_poly$status <- statusLab[k]
    sum_poly
    
    } else {
      
      sum_poly <- data.frame("number"=0, "area"=0, "trend"=unique(temp1$trend) , "change"=unique(temp1$change ), "level2"=trendChangeLabs[j], "percent"=0, "status"=statusLab[k])
      
    }
 
    
   
    
    
   
    #else {
      
     # next
      #print("change type not present")
      
   # }
    
    
       }
    
    }
  
  
}


chPoly$periodYrLabs3 <- ifelse(chPoly$change=="ch1", periodYrLabs3[1], ifelse(chPoly$change=="ch2", periodYrLabs3[2], periodYrLabs3[3]) )
chPoly$trend <-  paste0(tools::toTitleCase(chPoly$trend), "ing")



# ------------------------------------------------------
# This plot shows greening and browning side by side
# Note that when adding protected status info, the only metric that continues ot make sense is percentages

# Create plot, Number of polygons
# png(file=paste0(outf1, "gr_br_poly_change", "_npatches_global1", ".png"),
#     units = "in",
#     width = 6,
#     height = 3.5,
#     res = 300)
# 
# # Colour used in QGIS
# # Use position=position_dodge()
# ggplot(data=chPoly, aes(x=periodYrLabs3, y=number, fill=level2)) +
#   geom_bar(stat="identity", position=position_dodge()) + ylab("Number of patches") + xlab("Period comparison") + 
#   scale_fill_manual(values=c("#f28304", "#cc0c24", "#305a02", "#7ee61c", "#181e1e")) +
#   facet_grid(~ factor(trend, c("Greening", "Browning"))) + theme(legend.position="bottom") + labs(fill = "Change type:")
# 
# 
# dev.off()
# 
# 
# # Create plot, average area of polygons. This metric may be related to neighbour definition
# png(file=paste0(outf1, "gr_br_poly_change", "_avg_area_global1", ".png"),
#     units = "in",
#     width = 6,
#     height = 3.5,
#     res = 300)
# 
# # Colour used in QGIS
# # Use position=position_dodge()
# ggplot(data=chPoly, aes(x=periodYrLabs3, y=avg_area, fill=level2)) +
#   geom_bar(stat="identity", position=position_dodge()) + ylab("Average area of patches") + xlab("Period comparison") + 
#   scale_fill_manual(values=c("#f28304", "#cc0c24", "#305a02", "#7ee61c", "#181e1e")) +
#   facet_grid(~ factor(trend, c("Greening", "Browning"))) + theme(legend.position="bottom") + labs(fill = "Change type:")
# 
# 
# dev.off()


# Create plot, percent of polygons relative to trend (greening or browning) area
png(file=paste0(outf1, "gr_poly_change", "_per_area_patches_pro_global1", ".png"),
    units = "in",
    width = 6,
    height = 3.5,
    res = 300)

# Colour used in QGIS
# Use position=position_dodge()
ggplot(data=chPoly[chPoly$trend=="Greening",], aes(x=periodYrLabs3, y=percent, fill=level2)) +
  geom_bar(stat="identity", position=position_dodge()) + ylab("Patch percent of area") + xlab("Period comparison") + 
  scale_fill_manual(values=c("#f28304", "#cc0c24", "#305a02", "#7ee61c", "#181e1e")) +
  facet_grid(~ factor(status, c("Protected", "Non-protected"))) + theme(legend.position="bottom") + labs(fill = "Change type:")

dev.off()


png(file=paste0(outf1, "br_poly_change", "_per_area_patches_pro_global1", ".png"),
    units = "in",
    width = 6,
    height = 3.5,
    res = 300)

ggplot(data=chPoly[chPoly$trend=="Browning",], aes(x=periodYrLabs3, y=percent, fill=level2)) +
  geom_bar(stat="identity", position=position_dodge()) + ylab("Patch percent of area") + xlab("Period comparison") + 
  scale_fill_manual(values=c("#f28304", "#cc0c24", "#305a02", "#7ee61c", "#181e1e")) +
  facet_grid(~ factor(status, c("Protected", "Non-protected"))) + theme(legend.position="bottom") + labs(fill = "Change type:")

dev.off()


# ------------------------------------------------
# Get browning and greening per protected status
# ------------------------------------------------
library(sqldf)

p1Poly <- sqldf::sqldf("SELECT 1 as period, trend, change, status, periodYrLabs3, sum(area) area, sum(number) as number FROM chPoly
WHERE level2 IN ('cont','disa','stbl') and change='ch1'
GROUP BY trend, change, status, periodYrLabs3")

p2Poly <- sqldf::sqldf("SELECT 2 as period, trend, change, status, periodYrLabs3, sum(area) area, sum(number) as number FROM chPoly
WHERE level2 IN ('expn','genr','stbl') and change='ch1'
GROUP BY trend, change, status, periodYrLabs3")

p3Poly <- sqldf::sqldf("SELECT 3 as period, trend, change, status, periodYrLabs3, sum(area) area, sum(number) as number FROM chPoly
WHERE level2 IN ('cont','disa','stbl') and change='ch3'
GROUP BY trend, change, status, periodYrLabs3")

p4Poly <- sqldf::sqldf("SELECT 4 as period, trend, change, status, periodYrLabs3, sum(area) area, sum(number) as number FROM chPoly
WHERE level2 IN ('expn','genr','stbl') and change='ch3'
GROUP BY trend, change, status, periodYrLabs3")

periodPoly <- rbind.data.frame(p1Poly, p2Poly, p3Poly, p4Poly)

periodPoly$percent <- ifelse(periodPoly$status=='Non-protected', periodPoly$area/nonproforestAreaHa*100, periodPoly$area/proforestAreaHa*100)



png(file=paste0(outf1, "gr_br_poly", "_per_area_patches_pro_global1", ".png"),
    units = "in",
    width = 6,
    height = 3.5,
    res = 300)

ggplot(data=periodPoly, aes(x=period, y=percent, fill=trend)) +
  geom_bar(stat="identity", position=position_dodge()) + ylab("Patch percent of area") + xlab("Period") + 
  #scale_fill_manual(values=c("#f28304", "#cc0c24", "#305a02", "#7ee61c", "#181e1e")) +
  scale_fill_manual(values=c("#b96216", "#418a1c")) +
  facet_grid(~ factor(status, c("Protected", "Non-protected"))) + theme(legend.position="bottom") + labs(fill = "Trend type:")

dev.off()



# ggplot(data=chPoly, aes(x=periodYrLabs3, y=avg_area, fill=level2)) +
#   geom_bar(stat="identity", position=position_dodge()) + ylab("Average area of patches") + xlab("Period comparison") + 
#   scale_fill_manual(values=c("#f28304", "#cc0c24", "#305a02", "#7ee61c", "#181e1e")) +
#   facet_grid(~ factor(trend, c("Greening", "Browning"))) + theme(legend.position="bottom") + labs(fill = "Change type:")


#-------------------------------------------------------------------
# Get Greening and browning area to check with areas estimated above
#-------------------------------------------------------------------

# I checked several areas and they do match. So, it is ok to derived green and browning with
# protective status from object chPoly which contains changing polygon data

pgTabs2 <- c(paste0("evi_poly_type1_16d2_p",1:4), paste0("evi_poly_type2_16d2_p",1:4))

# Read tables found in Pstgres  
pgTabsL2 <- foreach(i=1:length(pgTabs2)) %do% {
  
  temp1 <- st_read(con1, layer = pgTabs2[i])
  st_crs(temp1) <- proj1
  st_transform(temp1, proj1)
  
}

checkAreas <- foreach (i=1:length(pgTabsL2), .combine = rbind) %do% {
  
  temp1 <- sf::st_transform(pgTabsL2[[i]], 3347)
  
  temp1$trend <- substr(pgTabs2[i] , start = 10, stop = 14) # extract trend name from files name
  
  temp1$change <- substr(pgTabs2[i], start = 21, stop = 22) # extract change name from files name
  
  sum_poly <- data.frame("number"=nrow(temp1), "area"= as.numeric(sum(sf::st_area(temp1)))/10000)
  
  sum_poly$"trend" <- unique(temp1$trend)
  sum_poly$"change" <- unique(temp1$change)
  sum_poly$"level2" <- unique(temp1$"level2") 
  #sum_poly$percent_for <- (sum_poly$area/sum_area)*100
  sum_poly$percent <- (sum_poly$area/forestAreaHa)*100
  #sum_poly$avg_area <- sum_poly$area/sum_poly$number  # number of polygons no longer makes sense when dividing by protected status because of a given patch can span both protected and non-protected forest polygons
  
  sum_poly


}

