#=================================================
# Climate variable time series plots
#=================================================

# 2025-12-18

# code written with the help of ChatGPT.

library(terra)

outf1<- "C:/Users/Peter R/Documents/forc_stamp/output1/img/"


files1 <- list.files("D:/data/ClimateNA_data/version3/", pattern="clim_na_CMI_sm_.*\\.tif$", full.names = TRUE)

stk1 <- rast(files1)
nlyr(stk1)

# Load raster stack / brick
#cmi <- rast("CMI_stack.tif")  # or already in memory

# Extract values for each layer
cmi_vals <- values(stk1, mat = TRUE)

# Optional: name layers as years
years <- 1998:(1998 + nlyr(stk1) - 1)
colnames(cmi_vals) <- years



png(file=paste0(outf1, "cmi_sm_time_series_boxplots_v1", ".png"),
    units = "in",
    width = 6.5,
    height = 4.5,
    res = 300)


# Boxplot
boxplot(
  cmi_vals,
  outline = FALSE,
  las = 2,
  ylab = "CMI in summer",
  xlab = "Year",
  main = "Annual CMI distribution"
)


# Add horizontal dashed line at CMI = 0
abline(
  h = 0,
  col = "red",
  lty = 2,
  lwd = 2
)

# ---- Vertical period boundary lines ----
# Define period boundaries in "year" units
period_bounds <- c(2002.5, 2007.5, 2012.5, 2017.5)

# Convert years to boxplot x positions
# Boxplot positions are 1, 2, 3, ..., n
year_to_x <- function(y, years) {
  approx(x = years, y = seq_along(years), xout = y)$y
}

x_positions <- year_to_x(period_bounds, years)

# Add vertical dashed lines
abline(
  v = x_positions,
  col = "blue",
  lty = 2,
  lwd = 2
)


dev.off()