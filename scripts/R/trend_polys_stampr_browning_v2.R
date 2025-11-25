#=================================================================================
# Spatio-temporal Pattern Analysis 
#=================================================================================
# 2024-09-12
# Peter R.

#  - Notes:
#   - This code is part of my Thesis Chapter 3
#   - Aim: Test driver stampr package
#   - The code is for running locally (not DRAC)
#   - The main strategy:  Trend raster polygons --> stamp
#   - There are 8 different types of trend classes
#   - We are looking at 4 periods: 2003-2007, 2008-2012, 2013-2017 & 2018-2022
#   - Some trend classes are not available for all periods. Mostly only classes 1 & 2 when using 5-year periods.

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
library(stampr) # this loads version 0.2 which seems to work with spdep/sp

# for radar plots
library(fmsb)
library(scales)
library(RColorBrewer)

 library(ggplot2)
 library(tidyr)




#=================================
# File paths and folders
# ================================

#setwd("C:/Users/Peter R/Documents/st_trends_for_c/algonquin")
setwd("C:/Users/Peter R/Documents/forc_stpa/")


infolder1 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h1yr/EVI_250m/bfast01/"
#infolder2 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
infolder2 <- "C:/Users/Peter R/Documents/forc_stpa/input1/"

outf2 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
outf3 <- "C:/Users/Peter R/Documents/forc_stpa/output1/gis/"
outf4 <- "C:/Users/Peter R/Documents/forc_stpa/output1/data/"
outf5 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"

# Study area bounding box
shp1 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection
#shp1 <- "~/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1.shp"
shp2 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/study_area_subset_v3.shp" # EPSG:3347




#--------------------------------------------------
# Read data
#--------------------------------------------------

files1 <- list.files(path=infolder2, recursive = TRUE, pattern = '\\.shp$', full.names=TRUE)

#files1 <- files1[-grep("flag", files1, fixed=T)]

# Only choose files from a given trend type (e.g., greening)
files1 <- files1[c(2,4,6,8)]  # Edit as needed 

# load polygons
polyL <- list()

polyL <- foreach (i=1:length(files1)) %do% {

  temp1 <- sf::st_read(files1[i])
  #temp1$ID <- 1:nrow(temp1)
  sf::st_transform(temp1, crs = st_crs(3347))
  
}

length(polyL)
#class(polyL[[1]])
#st_crs(polyL[[7]])

#poly1L <- polyL[c(1,3,5,7)]


#readRDS(paste0(outf4, "polyChBrown.rds"))

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



#------------------------------------------------------
# Global change metrics
#------------------------------------------------------

globalP1 <- glob.change(polyL[[1]], polyL[[2]])
globalP2 <- glob.change(polyL[[2]], polyL[[3]])
globalP3 <- glob.change(polyL[[3]], polyL[[4]])


# Prepare df for ggplot
globalAll <- as.data.frame(rbind((do.call( cbind, globalP1)),
   (do.call( cbind, globalP2)),
   (do.call( cbind, globalP3))))
   globalAll$label <- c("1 vs. 2", "2 vs. 3", "3 vs. 4")

# make df long to use faceting  
globalAllLong <- gather(globalAll, key="measure", value="value", c("NumRatio","AreaRatio", "AvgAreaRatio"))
 
globalAllLong$measure2 <- ifelse(globalAllLong$measure=="NumRatio", "Number", ifelse(globalAllLong$measure=="AreaRatio", "Area", "Avg. Area"))

# Turn facet variable into fator to keep order
globalAllLong$measure2 <- factor(globalAllLong$measure2, levels=c('Number','Area','Avg. Area'))

# Create plot
png(file=paste0(outf5, trendLabs[2], "_global1", ".png"),
      units = "in",
      width = 6,
      height = 3.5,
      res = 300) 
      
 ggplot(globalAllLong, aes(x=label, y=value))+
  geom_bar(stat='identity', fill="sienna3")+
  facet_wrap(~measure2)   + ylab("Ratio")  +xlab("Period comparison, Browning")

dev.off()



#--------------------------------------------------
# Assign IDs
#--------------------------------------------------

polyL[[1]]$ID <- 1:nrow(polyL[[1]]) # period 1 

polyL[[2]]$ID <- (max(polyL[[1]]$ID) + 1):(max(polyL[[1]]$ID) + nrow(polyL[[2]])) #period 2

polyL[[3]]$ID <- (max(polyL[[2]]$ID) + 1):(max(polyL[[2]]$ID) + nrow(polyL[[3]])) #period 3

polyL[[4]]$ID <- (max(polyL[[3]]$ID) + 1):(max(polyL[[3]]$ID) + nrow(polyL[[4]])) #period 4




#--------------------------------------------------
#  Clean polygons (intersecting vertices)
#--------------------------------------------------
# Notes
# - I used Negative buffers to get rid of potential intersection of vertices at corners of raster polygonization

# - 5 buffers  for period 2 (2008-2012)
polyL2 <- foreach (i=1:length(polyL)) %dopar% {
          
          sf::st_buffer(
                polyL[[i]],
                dist=-1,
                nQuadSegs = 30,
                endCapStyle = "SQUARE",
                joinStyle = "MITRE",
                mitreLimit = 1,
                singleSide = FALSE
                )  
                          
          }
          
# -1 buffers for period1 (2003-2007) and period 4 (2018-2022)
#polyL2[[1]]  <- sf::st_buffer(
#                polyL[[1]],
#                dist=-1,
#                nQuadSegs = 30,
#                endCapStyle = "SQUARE",
#                joinStyle = "MITRE",
#                mitreLimit = 1,
#                singleSide = FALSE
#                )
#                
#polyL2[[4]]  <- sf::st_buffer(
#                polyL[[4]],
#                dist=-1,
#                nQuadSegs = 30,
#                endCapStyle = "SQUARE",
#                joinStyle = "MITRE",
#                mitreLimit = 1,
#                singleSide = FALSE
#                ) 
#                
#polyL2[[3]]  <- sf::st_buffer(
#                polyL[[3]],
#                dist=-5,
#                nQuadSegs = 30,
#                endCapStyle = "SQUARE",
#                joinStyle = "MITRE",
#                mitreLimit = 1,
#                singleSide = FALSE
#                )                        
#          

length(polyL2)
#plot(st_geometry(polyL2[[1]]), col="green")


# ----------------------------------------------------------
# Stamp function: dc=0 otherwise you get errors perhaps due to geometry issues.
# ----------------------------------------------------------

# Notes
# - Before running stamp() you need to create unique IDs
# - Stamp() function takes a long time to run. For the pilot study it took up to 15 minutes for a single run
# It seems that intersecting vertices make direction and distance fail.

# Greening polygons
polyChGr <- list()

polyChGr[[1]] <- stamp(polyL2[[1]], polyL2[[2]], dc = 0, direction = FALSE, distance = FALSE)

polyChGr[[2]] <- stamp(polyL2[[2]], polyL2[[3]], dc = 0, direction = FALSE, distance = FALSE)

polyChGr[[3]] <- stamp(polyL2[[3]], polyL2[[4]], dc = 0, direction = FALSE, distance = FALSE)

#saveRDS(polyChGr,  paste0(outf4, "polyChBrown.rds"))

#readRDS(paste0(outf4, "polyChBrown.rds"))

# Write poly to shp
#st_write(polyCh1, paste0("./output1/gis/", "polyCh2_1to7.shp"))

#st_write(polyCh1, paste0("./output1/gis/", "polyCh2_2to8.shp"))


#--------------------------------------------------
# Summarize events
#--------------------------------------------------

chGrSum <- foreach (i=1:length(polyChGr)) %do% {
 
 temp1 <- stamp.group.summary(polyChGr[[i]])
 temp1[temp1$nEVENTS > 0, ] # note the 0 for browning

}

#length(chGrSum)


#--------------------------------------------------
# Plots 1
#--------------------------------------------------

# labels for plots

chPerLabs <- c("Period 1 vs. 2", "Period 2 vs. 3", "Period 3 vs. 4")

# labels for folder & files names
trendLabs <- c("greening", "browning")

# Subplot containers, 3 rows 1 column

png(file=paste0(outf5, trendLabs[2],"_prop_change_events1", ".png"),
      units = "in",
      width = 5,
      height = 6,
      res = 300)
      
par(mfrow = c(3,1))

# Add facet wrap
for (i in 1:length(chGrSum)) {
    
    plot((chGrSum[[i]]$aEXPN / chGrSum[[i]]$AREA) * 100, (chGrSum[[i]]$aCONT / chGrSum[[i]]$AREA) * 100,  xlab = " % Expansion", ylab = " % Contraction", pch = 20, ylim = c(0, 100), xlim = c(0, 100), cex = 2,
         main=paste0("Change: ", chPerLabs [i]))
         
         abline(a=0, b=1)

     }

# back to default, 1 row & 1 column     
par(mfrow = c(1,1))

dev.off()


#class(polyChGr[[1]])
#dim(polyChGr[[1]])
#stamp.map(polyChGr[[3]], by="LEV3")


#------------------------------------------
# Save objects as shp files
#------------------------------------------

# level is hard coded for now

# labels for folder & files names
#trendLabs <- c("greening", "browning")

stamprLevLabs <- c("lev1", "lev2", "lev3")


foreach (i=1:length(polyChGr)) %do% {
      
      dir.create(file.path(outf3, paste0("stampr_", stamprLevLabs[1])))   
         
     st_write(polyChGr[[i]], paste0(outf3, paste0("stampr_", stamprLevLabs[1]), "/",trendLabs[2], "_comp",i,".shp"), append=FALSE)    
         
         }

#The trick was dc=0 above in stamp(). No need to remove wholes but negative buffer is due to intersecting vertices.


# --------------------------------------------------------
# Distance analysis
# --------------------------------------------------------
polyChGrDistL <- foreach(i=1:length(polyChGr)) %dopar%  {

             stampr::stamp.distance(polyChGr[[1]], dist.mode = "Centroid", group = FALSE) # "Hausdorff", "Centroid"    
                        }


polyChGrDistL[[3]]

# --------------------------------------------------------
# Direction analysis
# --------------------------------------------------------

polyChGrDirL <- foreach(i=1:length(polyChGr)) %dopar% {
                stampr::stamp.direction(polyChGr[[i]], dir.mode = "ConeModel", ndir = 4, group = FALSE) # "CentroidAngle", "ConeModel", "MBRModel"
                }
                


#--------------------------------------------------
# Plots - Radar with directional values
#--------------------------------------------------
# radar plots showing direction of movement

# Create object to use for creating radar plots 

ChGrDirClassL <- foreach(i=1:length(polyChGrDirL))  %do% {
         
     temp1 <-  polyChGrDirL[[i]][polyChGrDirL[[i]]$LEV2 %in% c("CONT", "EXPN"), c("LEV2", "DIR0", "DIR90", "DIR180", "DIR270"), drop=TRUE]
     
      aggregate(. ~ LEV2, data=temp1, FUN=sum )
         
         }
 
#class(ChGrDirClassL[[1]])


# These metrics are needed for the radar plot
# Logged values may work better

# Summarize data for radar plot



# figure out the limits (max & min) of the direction values

radarPlotLimits <- foreach(i=1:length(ChGrDirClassL)) %do% {
        
    max1 <-  max(c(ChGrDirClassL[[i]][,"DIR0"], ChGrDirClassL[[i]][,"DIR90"], ChGrDirClassL[[i]][,"DIR180"],ChGrDirClassL[[i]][,"DIR270"]))
    
    min1 <-  min(c(ChGrDirClassL[[i]][,"DIR0"], ChGrDirClassL[[i]][,"DIR90"], ChGrDirClassL[[i]][,"DIR180"],ChGrDirClassL[[i]][,"DIR270"]))
    
      log1p(c(max1, min1))
        
        }
        

# c(5.1,4.1,4.1,2.1) in order c(bottom, left, top, right)
#old.par = par(mar = c(3, 4, 1, 2)) 
#par(old.par)
# for default margins:
# par("mar")

png(file=paste0("~/forc_stpa/", trendLabs[2], "_direction1", ".png"),
      units = "in",
      width = 6,
      height = 3.5,
      res = 300)
  
  par(xpd=TRUE) 
  
  par(mfrow = c(1,3))
  
  par(mar=c(5.1,2.1,4.1,2.1))
  
# color palette
cols <- brewer.pal(8,"Paired")
# Pixk colours from pallete
index1 = c(2,4)


foreach(i=1:length(radarPlotLimits)) %do% {
        
        radarchart(rbind(rep(radarPlotLimits[[i]][1],4), rep(radarPlotLimits[[i]][2],4), log1p(ChGrDirClassL[[i]][c(2,5,4,3)])),
           #custom polygon
             pcol=cols[index1], pfcol=alpha("grey",0.3), plwd=2, plty=1,
             #custom the grid
             cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,7,5), cglwd=1,
             #custom labels
             vlabels = c("North", "West          ", "South", "          East") ,
             vlcex=0.8,
             
             title=chPerLabs[i]       
           )        


  legend(-1.3,-1.3,
         legend=paste0(c("Contraction","Expansion")),
         col=cols[index1],
         lty=c(1),
         lwd = 2,
         bty = "n")
         
         }
         
  # back to default, 1 row & 1 column     
par(mfrow = c(1,1))
  
dev.off()



#plot(st_as_sf(mpb['TGROUP']))


#------------------------------------------------------
# Analysis With more than two time periods at a time
#-----------------------------------------------------
# Couldn't get the cod to work. But it seems stamp.multichange is just a wrapper which is handy.

#polyComb <- (rbind(polyL[[1]], polyL[[2]], polyL[[3]], polyL[[4]]))


#polyCh1Multi <- stamp.multichange(polyComb, changeByRow = FALSE, changeField ='period', distance=FALSE, direction=FALSE) # Did not work but error is strange: only defined for equally-sized data frames.
            

