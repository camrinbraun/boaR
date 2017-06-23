require(fields)
# some good color ramps for gradient mapping
sstgradcol =   colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan","#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"), interpolate = 'spline', bias = 2.5)
chlgradcol =   colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan","#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"), interpolate = 'spline', bias = 1.5)
# load some satelite data originally downloaded here (as a netcdf file):  http://coastwatch.pfeg.noaa.gov/erddap/griddap/index.html
data(satdata)
# Blended SST image
attach(sst)
t1 <- Sys.time()
tfront = boa(lon, lat, DATA, direction = T)
t2 <- Sys.time()


par(mfrow=c(1,2))
image.plot(lon, lat, tfront[[1]])
title('Direction')
image.plot(lon, lat, tfront[[2]]) # could use col = sstgradcol(100) for a different scale
title('Gradient Magnitude')
detach(sst)


# SeaWifs chlorophyll image
x11()
attach(swchl)
cfront = boa(swlon, swlat, log(chl), direction = T)  # be sure to take the log of the chl 
par(mfrow=c(1,2))
image.plot(swlon, swlat, cfront[[1]])
title('Direction')
image.plot(swlon, swlat, cfront[[2]], col = chlgradcol(100))
title('Gradient Magnitude (Ratio)')
detach(swchl)


# TRY ON OUR OWN DATA
require(RNetCDF)
nc <- open.nc('~/Downloads/jplG1SST_2cb2_3234_49a7.nc')
g1 <- var.get.nc(nc, 'SST')
lon <- var.get.nc(nc, 'longitude')
lat <- var.get.nc(nc, 'latitude')
dates <- as.POSIXct('2016-10-17')
g1sst <- list(lon = as.numeric(lon), lat = as.numeric(lat), dates = dates, DATA = g1)
t3 <- Sys.time()
gfront = boa(g1sst$lon, g1sst$lat, g1sst$DATA, direction = T)
t4 <- Sys.time()
image.plot(lon, lat, gfront[[2]])

# STILL NEED TO FORMAT AND CLEAN UP PACKAGE

