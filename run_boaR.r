devtools::load_all()
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
nc <- open.nc('~/Documents/WHOI/Data/WhaleSharks/EnvData/sst/.nc')
g1 <- var.get.nc(nc, 'SST')
lon <- var.get.nc(nc, 'longitude')
lat <- var.get.nc(nc, 'latitude')
dates <- as.POSIXct('2016-06-14')
g1sst <- list(lon = as.numeric(lon), lat = as.numeric(lat), dates = dates, DATA = g1)
t3 <- Sys.time()
gfront = boa(g1sst$lon, g1sst$lat, g1sst$DATA, direction = T)
t4 <- Sys.time()
image.plot(lon, lat, gfront[[2]])

# STILL NEED TO FORMAT AND CLEAN UP PACKAGE
require(curl)
sp.lim <- list(lonmin=-80, lonmax=-60,
               latmin=35, latmax=45)
udates <- as.POSIXct('2017-06-14')
source('~/Documents/WHOI/RCode/HMMoce/R/get.env.r')
source('~/Documents/WHOI/RCode/HMMoce/R/get.ghr.sst.r')
sst.dir <- '~/Documents/WHOI/Data/WhaleSharks/EnvData/sst/'
get.env(udates, filename='whaleshark', type = 'sst', sst.type='ghr', spatLim = sp.lim, save.dir = sst.dir)

require(RNetCDF); require(fields)
nc.sst <- open.nc(paste(sst.dir, 'whaleshark_', udates,'.nc',sep=''))
lat.sst <- as.numeric(var.get.nc(nc.sst, 'latitude'))
lon.sst <- as.numeric(var.get.nc(nc.sst, 'longitude'))
sst <- var.get.nc(nc.sst, 'SST')
xlims <- c(sp.lim[[1]], sp.lim[[2]]); ylims <- c(sp.lim[[3]], sp.lim[[4]])
lon.idx.sst <- c(which.min((lon.sst - xlims[1])^2):which.min((lon.sst - xlims[2])^2))
lat.idx.sst <- c(which.min((lat.sst - ylims[1])^2):which.min((lat.sst - ylims[2])^2))
g1sst <- list(lon = as.numeric(lon.sst[lon.idx.sst]), lat = as.numeric(lat.sst[lat.idx.sst]), dates = udates, DATA = sst[lon.idx.sst,lat.idx.sst])
t3 <- Sys.time()
gfront = boa(g1sst$lon, g1sst$lat, g1sst$DATA, direction = T)
t4 <- Sys.time()
image.plot(lon, lat, gfront[[2]])
world(add=T, fill=T, col='grey80', border='grey80')



# https://coastwatch.pfeg.noaa.gov/erddap/griddap/erdMH1chla8day.nc?chlorophyll[(2017-06-14T00:00:00Z):1:(2017-06-14T00:00:00Z)][(35):1:(45)][(-80):1:(-60)]

#erdMH1chla8day_dc49_6575_6a5b

nc <- open.nc('~/Documents/WHOI/Data/WhaleSharks/EnvData/chl/erdMH1chla8day_dc49_6575_6a5b.nc')
lat <- as.numeric(var.get.nc(nc, 'latitude'))
lon <- as.numeric(var.get.nc(nc, 'longitude'))
chl <- var.get.nc(nc, 'chlorophyll')
xlims <- c(sp.lim[[1]], sp.lim[[2]]); ylims <- c(sp.lim[[3]], sp.lim[[4]])
lon.idx <- c(which.min((lon - xlims[1])^2):which.min((lon - xlims[2])^2))
lat.idx <- c(which.min((lat - ylims[1])^2):which.min((lat - ylims[2])^2))
chl <- list(lon = as.numeric(lon[lon.idx]), lat = as.numeric(lat[lat.idx]), dates = udates, DATA = chl[lon.idx,lat.idx])
t3 <- Sys.time()
chlfront = boa(chl$lon, chl$lat, log(chl$DATA), direction = T)
t4 <- Sys.time()
image.plot(lon, lat, chlfront[[2]])
world(add=T, fill=T, col='grey80', border='grey80')

par(mfrow=c(1,2))
image.plot(g1sst$lon, g1sst$lat, gfront[[2]])
world(add=T, fill=T, col='grey80', border='grey80')

image.plot(chl$lon, chl$lat, chlfront[[2]])
world(add=T, fill=T, col='grey80', border='grey80')

pdf('try2.pdf', width=12, height=8)
image.plot(g1sst$lon,g1sst$lat, g1sst$DATA, xlab='',ylab='')
contour(add=T, g1sst$lon, g1sst$lat, gfront[[2]], levels=seq(.15,max(gfront[[2]],na.rm=T), by=.1))
world(add=T, fill=T, col='grey80', border='grey80')
text(-78, 44, 'SST W/FRONTS')

image.plot(chl$lon,chl$lat, log(chl$DATA), xlab='',ylab='')
contour(add=T, chl$lon, chl$lat, chlfront[[2]], levels=seq(.15,max(chlfront[[2]],na.rm=T), by=.1))
world(add=T, fill=T, col='grey80', border='grey80')
text(-78, 44, 'CHL W/FRONTS')
dev.off()

image.plot(chl$lon,chl$lat, log(chl$DATA), xlab='',ylab='', zlim=c(100,101))
contour(add=T, chl$lon, chl$lat, chlfront[[2]], levels=seq(.15,max(chlfront[[2]],na.rm=T), by=.1))
contour(add=T, col='grey',g1sst$lon, g1sst$lat, gfront[[2]], levels=seq(.15,max(gfront[[2]],na.rm=T), by=.1))


