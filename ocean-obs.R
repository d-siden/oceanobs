#''
#rm (list = ls())
options("rgdal_show_exportToProj4_warnings"="none")
library(rgdal, include.only = 'readOGR')
library(ggplot2)

# Devolver em CSV, PNG, e/ou só visualizar imagem?
devolve.csv <- FALSE
devolve.png <- FALSE
abrir.imagem <- TRUE

# onde salvar?
saida <- "/dados"

# varivável para plotar:
qual.var <- "PRES"

# área para plotar
if(abrir.imagem || devolve.png){
  lats <- c(-40, 10)
  lons <- c(-50, 10)
}

# shapefiles de fundo
continentes <- readOGR(sprintf("%s/shapes", getwd()), layer = "ne_50m_coastline", verbose = F)

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

if(devolve.csv){
  for(datas in unique(obs$DD)){
    data <- paste( as.character(obs[obs$DD==datas,4][1]),
                  as.character(obs[obs$DD==datas,3][1]),
                  as.character(obs[obs$DD==datas,2][1]), sep = "-")
    
    print(sprintf("Foram obtidas %i observações do dia %s",
                  nrow(obs[obs$DD==datas, ]), data))
    write.csv(obs[obs$DD==datas,],
              file = sprintf("%s%s/SHIP_obs_em_%s.csv", getwd(), saida, data),
              row.names = F)
  }
  print(sprintf("Totalizando %i observações salvas em csv", nrow(obs)))
}

if(abrir.imagem || devolve.png){
  cat("Períodos disponíveis:\n")
  for(dias in unique(obs$DD))
    {
    cat(sprintf("Dia %i\n", dias))
    cat("Horas: ")
    for (horas in unique(obs[obs$DD==dias,5])) {
      cat(sprintf("%i ", horas))
    }
    cat("\n")
  }
  repeat{
    dia <- readline("Escolher dia: ")
    if(dia %in% unique(obs$DD)){break}
  }
  repeat{
    hora <- readline("Escolher hora: ")
    if(hora %in% unique(obs[obs$DD==dia,5])){break}
  }
  
  selecao <- obs[obs$DD==dia & obs$hh==hora, ]
  
  minha.imagem <- ggplot()+
    geom_path(data = continentes,
              aes(x = long, y = lat, group=group),
              size = 0.4)+
    geom_point(data = selecao,
               aes(x = LON, y = LAT))+
    geom_text(data = selecao,
               aes(x = LON, y = LAT),
               label = selecao$SHIP_ID,
              nudge_x = 0.05)+
    coord_fixed(ratio = 27.5/25,
                xlim = lons,
                ylim = lats,
                expand = FALSE)+
    ggtitle(sprintf("Observações de __ às %s UTC do dia %s", hora, dia))+
    theme_light()
}

if(abrir.imagem){
  x11()
  print(minha.imagem)
}

if(devolve.png){
  png(file=sprintf("%s%s/SHIP_obs_em_.png", getwd(), saida), res=300)
  print(minha.imagem)
  graphics.off()
  cat("\t Imagem salva")
}
