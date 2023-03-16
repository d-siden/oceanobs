# ler observações SHIP em url ou arquivo

procurar.ship <- function(endereco="https://www.ndbc.noaa.gov/data/realtime2/ship_obs.txt")
{
  obs <- read.table(
    url(endereco),
    header = F,
    dec = ".",
    na.strings = "MM",
    stringsAsFactors = F
  )
  

  
}