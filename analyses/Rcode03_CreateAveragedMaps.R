lst.indic <- c('bio01d', 'bio04d', 'bio12d', 'bio15d','cdd', 'fd','gdd5','prsd', 'scd', 'swe') # pas 2019, 2020 pour prsd

#### REMOVE bio15d 2020 before running this script ####

for (l in lst.indic) {
  
  ffiles <- list.files(here::here(paste0('data/derived-data/', l)))
  r.stack = c()
  lst.year <- c()
  
  for (f in ffiles) {
  r <- terra::rast(here::here(paste0('data/derived-data/', l, '/',f)))
  r.stack <- c(r.stack, r)
  lb <- strsplit(f, '_')
  lst.year <- c(lst.year, lb[[1]][5])
  }
  
  r.stack <- terra::rast(r.stack)
  r.stack <- terra::mean(r.stack)
  
  terra::writeRaster(r.stack, here::here(paste0('outputs/CHELSA_EUR11_obs_', l, '_AnnualMeanOver',lst.year[1],'-',lst.year[length(lst.year)],
                                                '_V2.1.tif')), overwrite = T)
}
