

options(timeout = max(3000000000, getOption("timeout")))

lst.indic <- c('bio01d', 'bio04d', 'bio12d', 'bio15d','cdd', 'fd','gdd5','prsd', 'scd', 'swe') # pas 2019, 2020 pour prsd
lst.yrs <- c(2010:2020)

p1 <- 'https://os.zhdk.cloud.switch.ch/envicloud/chelsa/chelsa_V2/EUR11/obs/annual/V2.1/'
p2 <- '/CHELSA_EUR11_obs_'
p3 <- '_V.2.1.nc'
lst.url <- expand.grid(years = lst.yrs, indic = lst.indic)
lst.url$url <- paste0(p1, lst.url$indic, p2, lst.url$indic, '_', lst.url$years, p3)

for (i in lst.indic) {
  dir.create(here::here('data/raw-data/download/', i))
}

for (l in lst.url$url) {
  lb <- strsplit(l, '/', fixed = T)
  lb <-  unlist(lb)
  lb <- lb[length(lb)]
  downloader::download(l, dest=here::here(paste0('data/raw-data/download/', lst.url$indic[lst.url$url == l],'/', lb)), mode="wb") 
  }

