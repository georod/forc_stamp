#=================================================================================
# Spatio-temporal Pattern Analysis 
#=================================================================================
# 2024-07-30
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





#=================================
# File paths and folders
# ================================

#setwd("C:/Users/Peter R/Documents/st_trends_for_c/algonquin")
setwd("C:/Users/Peter R/Documents/forc_stpa/")


infolder1 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h1yr/EVI_250m/bfast01/"
infolder2 <- "C:/Users/Peter R/Documents/forc_stpa/input1/"

outf2 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"


# Study area bounding box
shp1 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection
#shp1 <- "~/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1.shp"
shp2 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/study_area_subset_v3.shp" # EPSG:3347




#===================================
# Read data

files1 <- list.files(path=infolder2, recursive = TRUE, pattern = '\\.shp$', full.names=TRUE)

#files1 <- files1[-grep("flag", files1, fixed=T)]



polyL <- list()

polyL <- foreach (i=1:length(files1)) %do% {

  temp1 <- sf::st_read(files1[i])
  #temp1$ID <- 1:nrow(temp1)
  sf::st_transform(temp1, crs = st_crs(3347))
  
}

length(polyL)
#class(polyL[[1]])
#st_crs(polyL[[7]])


# assign IDs
polyL[[1]]$ID <- 1:nrow(polyL[[1]]) # period 1 
#polyL[[7]]$ID <- (max(polyL[[1]]$ID) + 1):(max(polyL[[1]]$ID) + nrow(polyL[[7]])) #period 4

polyL[[3]]$ID <- (max(polyL[[1]]$ID) + 1):(max(polyL[[1]]$ID) + nrow(polyL[[3]])) #period 2

polyL[[2]]$ID <- (max(polyL[[1]]$ID) + 1):(max(polyL[[1]]$ID) + nrow(polyL[[2]]))


#polyL7NoHoles <- st_multipolygon(lapply(polyL[[7]], function(x) x[1])) # Did not work

polyL7NoHoles <- st_as_sf(terra::fillHoles(vect(polyL[[7]]), inverse=FALSE))
polyL1NoHoles <- st_as_sf(terra::fillHoles(vect(polyL[[1]]), inverse=FALSE))
polyL3NoHoles <- st_as_sf(terra::fillHoles(vect(polyL[[3]]), inverse=FALSE))

# Buffer to get rid of potential intersection at corners

polyL7NoHolesBuffNeg <- st_buffer(
polyL7NoHoles,
dist=-1,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)

polyL1NoHolesBuffNeg <- st_buffer(
polyL1NoHoles,
dist=-1,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)

polyL3NoHolesBuffNeg <- st_buffer(
polyL3NoHoles,
dist=-1,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)

polyL7BuffNeg <- st_buffer(
polyL[[7]],
dist=-1,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)


# Its seems we can't apply a systematic buffer.  L1 with -1 buffer works but not with -5.  L3 works with -5 but not with -1

# -1 works 
polyL1BuffNeg <- st_buffer(
polyL[[1]],
dist=-1,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)

# -5 does not work
polyL1BuffNeg <- st_buffer(
polyL[[1]],
dist=-5,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)

# Does not work
polyL3BuffNeg <- st_buffer(
polyL[[3]],
dist=-1,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)

# -5 works
polyL3BuffNeg <- st_buffer(
polyL[[3]],
dist=-5,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)

# -5 worked
polyL5BuffNeg <- st_buffer(
polyL[[5]],
dist=-5,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)


# -5 worked
polyL2BuffNeg <- st_buffer(
polyL[[2]],
dist=-5,
nQuadSegs = 30,
endCapStyle = "SQUARE",
joinStyle = "MITRE",
mitreLimit = 1,
singleSide = FALSE
)

sf::st_is_valid(polyL3BuffNeg )
#dev.new(); plot(st_geometry(polyL7NoHolesBuff), col="green")

st_write(polyL7NoHolesBuffNeg, paste0("./output1/gis/", "polyL7NoHolesBuffNeg2.shp"))

st_write(polyL1NoHolesBuffNeg, paste0("./output1/gis/", "polyL1NoHolesBuffNeg2.shp"))


st_write(polyL8NoHolesBuffNeg, paste0("./output1/gis/", "polyL8NoHolesBuffNeg2.shp"))

st_write(polyL2NoHolesBuffNeg, paste0("./output1/gis/", "polyL2NoHolesBuffNeg2.shp"))

st_write(polyL3BuffNeg, paste0("./output1/gis/", "polyL3BuffNeg2.shp"), append=FALSE) # period 2, greening


st_intersects(polyL1BuffNeg, sparse=FALSE)

st_overlaps(polyL1BuffNeg, sparse=FALSE)

st_contains(polyL1BuffNeg, sparse=FALSE)

# Stamp function.  When using dc=250 I got some strange errors (e.g. loop 0, edge 1864 crosses...). This error dissapears wehn dc=0. It seems to be when the polgons are groped intersection/geometry errors occur.

#polyCh1 <- stamp(polyL[[1]], polyL[[7]], dc = 0, direction = FALSE, distance = FALSE, shape = FALSE)

#polyCh1 <- stamp(
#   st_buffer(
#polyL[[1]],
#dist=-1,
#nQuadSegs = 30,
#endCapStyle = "SQUARE",
#joinStyle = "MITRE",
#mitreLimit = 1,
#singleSide = FALSE
#) , 
#st_buffer(
#polyL[[7]],
#dist=-1,
#nQuadSegs = 30,
#endCapStyle = "SQUARE",
#joinStyle = "MITRE",
#mitreLimit = 1,
#singleSide = FALSE
#)  , dc = 0, direction = FALSE, distance = FALSE, shape = FALSE)


polyCh1 <- stamp(polyL1NoHolesBuffNeg, polyL7NoHolesBuffNeg, dc = 0, direction = FALSE, distance = FALSE)

# whole fill not needed but overlapping vertices seems to have been the problem. This works.
polyCh1 <- stamp(polyL1BuffNeg, polyL7BuffNeg, dc = 0, direction = FALSE, distance = FALSE)

polyCh2 <- stamp(polyL1BuffNeg, polyL3BuffNeg, dc = 0, direction = FALSE, distance = FALSE)

polyCh3 <- stamp(polyL1BuffNeg, polyL5BuffNeg, dc = 0, direction = FALSE, distance = FALSE)

polyCh4 <- stamp(polyL1BuffNeg, polyL2BuffNeg, dc = 0, direction = FALSE, distance = FALSE)

# with L1 -5 buffer
polyCh44 <- stamp(polyL1BuffNeg, polyL2BuffNeg, dc = 0, direction = FALSE, distance = FALSE)


#polyCh1 <- stamp(polyL[[2]], polyL[[4]], dc = 0, direction = FALSE, distance = FALSE, shape = FALSE)

#crs(polyCh1)
#cat(sf::st_as_sf(polyCh1$wkt))

head(polyCh1)

#st_write(polyCh1, paste0("./output1/gis/", "polyCh2_1to7.shp"))

#st_write(polyCh1, paste0("./output1/gis/", "polyCh2_2to8.shp"))

chSum <- stamp.group.summary(polyCh1)

chSum2 <- chSum[chSum$nEVENTS > 1, ]

plot((chSum2$aEXPN / chSum2$AREA) * 100, (chSum2$aCONT / chSum2$AREA) * 100,  xlab = " % Expansion", ylab = " % Contraction", pch = 20, ylim = c(0, 100), xlim = c(0, 100), cex = 2)

class(polyCh1)
dim(polyCh1)
stamp.map(polyCh1)

# sf::st_project(sf::st_as_sf(polyCh1), "3347")

#st_is_valid(polyCh1)


# Even after filling holes and negative buffers the function won't work.
# This now works.  The trick was dc=0 above in stamp(). No need to remove wholes but negative buffer is due to intersecting vertices.
polyCh1Dist <- stamp.distance(polyCh1, dist.mode = "Centroid", group = FALSE) # "Hausdorff", "Centroid"

polyCh2Dist <- stamp.distance(polyCh2, dist.mode = "Centroid", group = FALSE)

polyCh3Dist <- stamp.distance(polyCh3, dist.mode = "Centroid", group = FALSE)

stamp.distance(polyCh4, dist.mode = "Centroid", group = FALSE)

stamp.distance(polyCh44, dist.mode = "Centroid", group = FALSE)

# Even after filling holes the function won't work.
polyCh1Dir <- stamp.direction(polyCh1, dir.mode = "ConeModel", ndir = 4, group = FALSE) # "CentroidAngle", "ConeModel", "MBRModel"
head(polyCh1Dir)
tail(polyCh1Dir)
dim((polyCh1Dir))

dir1 <- (polyCh1Dir[polyCh1Dir$LEV2 %in% c("CONT", "EXPN"),])
dim(dir1)

cols <- brewer.pal(8,"Paired")


plotFun <- function(C_data,timestep,Dirclass,index1){
  
  # add the max and min of each variable to show on the plot
  dataR <- rbind(rep(244000,4), rep(0,4), C_data)
 
  
  # PLot does not work
  # plot with default options
  png(file=paste0("~/forc_stpa/",timestep, ".png"),
      units = "in",
      width = 5,
      height = 5,
      res = 300)
  
  par(xpd=TRUE)
  
  radarchart(dataR,
             #custom polygon
             pcol=cols[index1], pfcol=alpha("grey",0.3), plwd=2, plty=1,
             #custom the grid
             cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,7,5), cglwd=1,
             #custom labels
             vlcex=0.8)
  
  legend(-1.3,-1.3,
         legend=paste0(Dirclass,c("Contraction","Expansion")),
         col=cols[index1],
         lty=c(1),
         lwd = 2,
         bty = "n")
  
  dev.off()
}


plotFun(C_data = data.frame(dir0=dir1$DIR0,
                            dir270=dir1$DIR270,
                            dir180=dir1$DIR180, 
                            dir90=dir1$DIR90 
                          ),
        Dirclass = "Class: ", 
        timestep = "step17",
        index1 = c(2,4))



#plot(st_as_sf(mpb['TGROUP']))


# With more than two time periods

polyL[[1]]$ID <- 1:nrow(polyL[[1]]) # period 1 
polyL[[3]]$ID <- (max(polyL[[1]]$ID) + 1):(max(polyL[[1]]$ID) + nrow(polyL[[3]])) #period 2
polyL[[5]]$ID <- (max(polyL[[3]]$ID) + 1):(max(polyL[[3]]$ID) + nrow(polyL[[5]])) #period 3
polyL[[7]]$ID <- (max(polyL[[5]]$ID) + 1):(max(polyL[[5]]$ID) + nrow(polyL[[7]])) #period 4

polyComb <- (rbind(polyL[[1]], polyL[[3]], polyL[[5]], polyL[[7]]))


polyCh1Multi <- stamp.multichange(polyComb, changeByRow = FALSE, changeField ='period', distance=TRUE, direction=FALSE) # Did not work but error is strange. Use  Tinn-R to test
            
