#===============================================================================
# create STAMP pixel data frame
#===============================================================================

# 2025-04-20
# Peter R.

# Aim 1: Convert STAMP polygons to pixel data frame to join with Duckdb.
#    - C:\Users\Peter R\Documents\forc_stpa\data\r1Agg2018Pj.tif

# Notes:
# - 
# - 
# - 
# - 


#=================================
# Load libraries
# ================================

library(terra)
library(dplyr)

library(sqldf)

library(foreach)


#------------------------------------------------------
# File paths and folders
# -----------------------------------------------------

#outf5 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/ver2/data/"

outf1 <- "~/forc_stpa/data/stamp_pix/"


fpath10 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h5p/EVI_250m/drac/rasters/EVI_negBrks_16d.tif"

#outf6 <- "C:/Users/Peter R/Documents/forc_stpa/data/"

outf2 <- "~/forc_stpa/output1/data/csv_duckdb/"
outf3 <- "C:/Users/Peter R/Desktop/duckdb/trends/"

#vect0 <-vect("C:/Users/Peter R/Documents/PhD/resnet/data/gis/misc/algonquin_envelope_500m_buff_v1.shp")

r10 <- rast(fpath10) # An alternative to using r2

#----------------------
# Harvest - time series  -- Not run
#----------------------



#------------------------------
# STAMP poly
#------------------------------


files1 <- list.files("~/forc_stpa/output1/change_poly/", pattern='_level2_v1.gpkg',full.names=TRUE)
files2 <- list.files("~/forc_stpa/output1/change_poly/", pattern='_level2_v1.gpkg',full.names=FALSE)

rPoly <- foreach(i=1:length(files1), .combine = rbind) %do% {
  
  shp1 <- vect(files1[i])
  shp1 <- project(shp1, r10)
  
  temp1 <- rasterize(shp1, r10, "level2")
  df1 <- as.data.frame(temp1, cells=TRUE, na.rm = TRUE)
  names(df1) <- c("pix", "stamp")
  df1$trend<- strsplit(files2[i],"_")[[1]][2]
  df1$change <- strsplit(files2[i],"_")[[1]][3]
 
  file_name <- gsub(".gpkg", ".csv", files2[i])
  
  # Save CSV
  write.csv(df1, paste0(outf2, file_name), na="", row.names = FALSE)
  write.csv(df1, paste0(outf3, file_name), na="", row.names = FALSE)
  
}


# Write a test raster to validate. Load in QGIS. The tif worked fine
#terra::writeRaster(temp1, "~/forc_stpa/output1/change_poly/evi_green_ch3_level2_v1.tif")


# To do
# - Use duck db to create binary version of STAMP values just as pro_0
# - used duckdb to joi with version 5 csv to create a new CSV
# - run XGBoost stamp models









