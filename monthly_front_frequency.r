# build monthly front frequency composites


library(HMMoce)
dte <- as.Date('2010-01-01')
sp.lim <- list(lonmin=-100, lonmax=-19,
               latmin=-2, latmax=59)
hycom.dir <- '~/ebs/EnvData/hycom/Swordfish/'

require(RNetCDF)

# download hycom sst for each day
get.env(dte, filename='bask', type = 'hycom', spatLim = sp.lim, depLevels=1, save.dir = hycom.dir)


for (yr){
  for (mnth){
    for (dy){
      # already done...download hycom sst
      #get.env(dte, filename='bask', type = 'hycom', spatLim = sp.lim, depLevels=1, save.dir = hycom.dir)
      
      # load hycom sst
      nc <- open.nc('~/ebs/EnvData/hycom/Swordfish/bask_2010-01-01.nc')
      if (dy == 1){
        lon <- var.get.nc(nc, 'lon')
        lat <- var.get.nc(nc, 'lat')
      }
      sst <- var.get.nc(nc, 'water_temp') * .001 + 20
      
      # calc fronts
      #g1sst <- list(lon = as.numeric(lon), lat = as.numeric(lat), DATA = g1)
      gfront = boa(as.numeric(lon), as.numeric(lat), sst, direction = T)
      
      # stack
      
      
    }
    # write out monthly stacks
    
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
