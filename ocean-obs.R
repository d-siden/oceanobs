#''
#rm (list = ls())
options("rgdal_show_exportToProj4_warnings"="none")
library(rgdal, include.only = 'readOGR')
library(ggplot2)

# Devolver em CSV, PNG, ou só visualizar imagem?
devolve.csv <- FALSE
devolve.png <- FALSE
abrir.imagem <- TRUE

# onde salvar?
saida <- ""

# varivável para plotar:
qual.var <- "PRES"

# área para plotar
if(abrir.imagem || devolve.png){
  lats <- c(-40, 10)
  lons <- c(-50, 10)
}

# shapefiles de fundo
continentes <- readOGR("/home/danilo/Documents/oceanobs/shapes", layer = "ne_50m_coastline", verbose = F)

#####################################################################
graphics.off()
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

if(abrir.imagem || devolve.png){
  minha.imagem <- ggplot()+
    geom_path(data = continentes,
              aes(x = long, y = lat, group=group),
              size = 0.4)+
    geom_point(data = obs,
               aes(x = LON, y = LAT))+
    geom_text(data = obs,
               aes(x = LON, y = LAT),
               label = obs$SHIP_ID,
              nudge_x = 0.05)+
    coord_fixed(ratio = 27.5/25,
                xlim = lons,
                ylim = lats,
                expand = FALSE)+
    theme_light()
}
x11()
print(minha.imagem)

