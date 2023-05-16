
# code developpe a partir de https://pjbartlein.github.io/REarthSysSci/netCDF.html#introduction

lst.indic <- c('bio01d', 'bio04d', 'bio12d', 'bio15d','cdd', 'fd','gdd5','prsd', 'scd', 'swe') # pas 2019, 2020 pour prsd
for (i in lst.indic) {
  dir.create(here::here('data/derived-data/', i))
}
df.var.name <-  data.frame()

for (l in lst.indic) {
  
  ffiles <- list.files(here::here(paste0('data/raw-data/download/', l)))
  
  for (f in ffiles) {
  
    ncin <- ncdf4::nc_open(here::here(paste0('data/raw-data/download/',l,'/',f)))
    
    # get longitude and latitude
    lon <- ncdf4::ncvar_get(ncin,"lon")
    nlon <- dim(lon)
    lat <- ncdf4::ncvar_get(ncin,"lat")
    nlat = dim(lat)
   
    # get info on variable
    v <-  names(ncin$var)[length(ncin$var)]
    dlname <- ncdf4::ncatt_get(ncin,v, "long_name")
    dunits <- ncdf4::ncatt_get(ncin,v,"units")
    fillvalue <- ncdf4::ncatt_get(ncin,v,"_FillValue")
    
    # get variable 
    tmp_array <- ncdf4::ncvar_get(ncin, varid = v)
    # replace netCDF fill values with NA's
    tmp_array[tmp_array==fillvalue$value] <- NA
    # reshape the array into vector
    tmp_vec_long <- as.vector(tmp_array)
    # reshape the vector into a matrix
    tmp_mat <- matrix(tmp_vec_long, nrow=nlon*nlat, ncol=1)
    
    # create a dataframe
    lonlat <- as.matrix(expand.grid(lon,lat))
    tmp_df02 <- data.frame(cbind(lonlat,tmp_mat))
    colnames(tmp_df02) = c('long','lat', l)
    
    # rasterize
    r <- terra::rast(tmp_df02, type = 'xyz')
    terra::crs(r) = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
    r = terra::project(r, '+proj=lcc +lat_0=46.5 +lon_0=3 +lat_1=49 +lat_2=44 +x_0=700000 +y_0=6600000 +ellps=GRS80 +units=m +no_defs')
    lb <- gsub('.nc','', f)
    terra::writeRaster(r, here::here(paste0('data/derived-data/',l,'/', lb, '.tif')), overwrite = T)
    
  }
  
  df.var.name <- rbind(df.var.name, data.frame(indic = l, var_short = v, var_long = dlname$value, units = dunits$value))
}

openxlsx::write.xlsx(df.var.name, here::here('data/derived-data/DescriptionIndicators_ChelsaAnnualV2.1_2010-2020.xlsx'))
