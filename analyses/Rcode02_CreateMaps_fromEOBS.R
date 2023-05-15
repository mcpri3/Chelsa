setwd("//2006ja20nas/UMS2006/070_CONSERVATION/PRIMA")

rm(list=ls())

# code developpe a partir de https://pjbartlein.github.io/REarthSysSci/netCDF.html#introduction
library(tidync)
library("ncdf4")
library("RNetCDF")
library(lattice)
library(RColorBrewer)
library(chron)
library(raster)
library(rgeos)

variables = c('tg','tn', 'tx','rr','qq','pp')
list.year = c(1950:2019)

for (v in variables) {
  
  print(v)

filename = paste0('./BasedeDonnees/SIG/E-OBS/',v,'_ens_mean_0.1deg_reg_v22.0e.nc')

# open a netCDF file
ncin <- nc_open(filename)

# get longitude and latitude
lon <- ncvar_get(ncin,"longitude")
nlon <- dim(lon)
lat <- ncvar_get(ncin,"latitude")
nlat = dim(lat)
# get time
time <- ncvar_get(ncin,"time")
tunits <- ncatt_get(ncin,"time","units")

# get info on variable
dlname <- ncatt_get(ncin,v, "long_name")
print(dlname$value)
dunits <- ncatt_get(ncin,v,"units")
fillvalue <- ncatt_get(ncin,v,"_FillValue")

# convert time -- split the time units string into fields
tustr <- strsplit(tunits$value, " ")
tdstr <- strsplit(unlist(tustr)[3], "-")
tmonth <- as.integer(unlist(tdstr)[2])
tday <- as.integer(unlist(tdstr)[3])
tyear <- as.integer(unlist(tdstr)[1])

# rasterize each year 

for (y in list.year) {
print(y)
t = chron(time,origin=c(tmonth, tday, tyear), out.format = "m/d/y")
t = as.POSIXct(t, format = '%m%d%Y')
idx = grep(paste0(y),t)
idx.start = min(idx)
ntbis = (max(idx)-min(idx)+1)

# get variable 
tmp_array <- ncvar_get(ncin, start=c(1,1,idx.start), count=c(length(lon), length(lat), ntbis))
# replace netCDF fill values with NA's
tmp_array[tmp_array==fillvalue$value] <- NA
# reshape the array into vector
tmp_vec_long <- as.vector(tmp_array)
# reshape the vector into a matrix
tmp_mat <- matrix(tmp_vec_long, nrow=nlon*nlat, ncol=ntbis)

# create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
tmp_df02 <- data.frame(cbind(lonlat,tmp_mat))
colnames(tmp_df02)[1:2] = c('long','lat')

# get the annual mean 
tmp_df02$mat <- apply(tmp_df02[3:ncol(tmp_df02)],1,mean) # annual (i.e. row) means

# rasterize
r <- rasterFromXYZ(tmp_df02[, c('long', 'lat', 'mat')])
r@crs = CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
r = projectRaster(r, crs = CRS('+proj=lcc +lat_0=46.5 +lon_0=3 +lat_1=49 +lat_2=44 +x_0=700000 +y_0=6600000 +ellps=GRS80 +units=m +no_defs'))

dunits$value = gsub('/','par', dunits$value)
writeRaster(r, paste0('./BasedeDonnees/SIG/E-OBS/TIFF/',v,'_',dunits$value,'_',y), format = 'GTiff', overwrite = T)

}

}

# Calcul de l'amplitude des temperatures 
rm(list=ls())
list.year = c(1950:2019)

for (y in list.year) {
  rr1 = raster(paste0('./BasedeDonnees/SIG/E-OBS/TIFF/tn_Celsius_',y,'.tif'))
  rr2 = raster(paste0('./BasedeDonnees/SIG/E-OBS/TIFF/tx_Celsius_',y,'.tif'))
  
  rr = rr2- rr1
  
  writeRaster(rr, paste0('./BasedeDonnees/SIG/E-OBS/TIFF/amp_Celsius_',y), format = 'GTiff', overwrite = T)
  
  print(y)
  
}
  

