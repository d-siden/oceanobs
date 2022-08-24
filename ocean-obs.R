# obter (e exibir, opcional) dados em código SHIP e boias

# lembrar de setar o pwd no terminal para documents

cabecalho <- c("SHIP_ID", "YY", "MM", "DD", "hh",
               "LAT", "LON", "WDIR", "WSPD", "GST", "WVHT",
               "DPD", "APD", "MWD", "PRES", "ATMP", "WTMP",
               "DEWP", "VIS", "PTDY", "TCC", "S1HT",
               "S1PD", "S1DIR", "S2HT", "S2PD", "S2DIR", "II",
               "IE", "IR", "IC", "IS", "Ib", "ID", "Iz"
)
unidades <- c("(estacao)", "(ano)", "(mes)", "(dia)", "(hora)",
               "(°)", "(°)", "(°T)", "(m/s)", "(m/s)", "(m)",
               "(s)", "(s)", "(°T)", "(hPa)", "(°C)", "(°C)",
               "(°C)", "(NM)", "(hPa)", "(octa)", "(m)",
               "(s)", "(°T)", "(m)", "(s)", "(°T)", "II",
               "IE", "IR", "IC", "IS", "Ib", "ID", "Iz"
               )
names(unidades) <- cabecalho


obs <- read.table(
  url('https://www.ndbc.noaa.gov/data/realtime2/ship_obs.txt'),
  header = F,
  dec = ".",
  na.strings = "MM",
  stringsAsFactors = F
  )

if (ncol(obs) != length(cabecalho)){
  stop("Cabeçalho não confere com os dados!")
}else{
  # colocar o cabeçalho no dataframe
  names(obs) <- cabecalho
  
}

