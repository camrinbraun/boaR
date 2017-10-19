# build monthly front frequency composites
# dates of interest are jan 1990 - dec 2009
# hycom reanalysis product starts at oct 02, 1992

dateseq <- seq.Date(as.Date('1992-10-02'), as.Date('2009-12-31'), 'day')
#library(HMMoce)
setwd('~/HMMoce'); devtools::load_all()
sp.lim <- list(lonmin=-100, lonmax=-19,
               latmin=-2, latmax=59)
hycom.dir <- '~/ebs/EnvData/hycom/Swordfish/'
require(RNetCDF)

# skipped 1552 bc that date didn't exist in data
for (i in 2038:length(dateseq)){
  # download hycom sst for each day
  get.env(dateseq[i], filename='hycom_sst', type = 'hycom', spatLim = sp.lim, depLevels=1, save.dir = hycom.dir)
}


require(RNetCDF); require(raster)
dts <- seq.Date(as.Date('1993-01-01'), as.Date('2009-12-31'), 'day')
u.years <- unique(lubridate::year(dateseq))
#1993-07-24
for (y in 1:length(u.years)){
  for (m in 1:12){
    dte.m <- dts[which(lubridate::year(dts) %in% u.years[y] & lubridate::month(dts) %in% m)]
    u.days <- unique(lubridate::day(dte.m))
    for (d in 1:length(u.days)){
      # already done...download hycom sst
      #get.env(dte, filename='bask', type = 'hycom', spatLim = sp.lim, depLevels=1, save.dir = hycom.dir)
      
      # load hycom sst
      dte.i <- dte.m[d]
      nc <- open.nc('~/ebs/EnvData/hycom/Swordfish/hycom_sst_2003-09-14.nc')
      if (d == 1){
        lon <- var.get.nc(nc, 'lon')
        lat <- var.get.nc(nc, 'lat')
      }
      sst <- var.get.nc(nc, 'water_temp') * .001 + 20
      
      # calc fronts
      #g1sst <- list(lon = as.numeric(lon), lat = as.numeric(lat), DATA = g1)
      #t1 <- Sys.time()
      gfront = boa(as.numeric(lon), as.numeric(lat), sst, direction = T)
      #t2 <- Sys.time()
      #t2 - t1
      # stack
      
      if (d == 1){
        s <- stack(raster(as.matrix(gfront$front)))#, xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs="+proj=longlat +ellps=WGS84 +datum=WGS84"))
      } else{
        s <- stack(s, raster(as.matrix(gfront$front)))
      }
      
    }
    # write out monthly stacks
    names(s) <- dte.m
    paste.m <- m
    if (nchar(paste.m) == 1) paste.m <- paste(0, m, sep='')
    writeRaster(s, filename = paste(u.years[y], paste.m, '_front_freq.grd', sep=''))
    
  }
}

# TRY ON OUR OWN DATA
nc <- open.nc('~/ebs/EnvData/hycom/Swordfish/bask_2010-01-01.nc')
sst <- var.get.nc(nc, 'water_temp') * .001 + 20
lon <- var.get.nc(nc, 'lon')
lat <- var.get.nc(nc, 'lat')
dates <- as.POSIXct('2016-06-14')
g1sst <- list(lon = as.numeric(lon), lat = as.numeric(lat), dates = dates, DATA = g1)
t3 <- Sys.time()
gfront = boa(g1sst$lon, g1sst$lat, g1sst$DATA, direction = T)
t4 <- Sys.time()
image.plot(lon, lat, gfront[[2]])
