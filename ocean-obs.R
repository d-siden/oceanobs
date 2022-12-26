# Busca as últimas observações feitas por navios

rm (list = ls())
options("rgdal_show_exportToProj4_warnings"="none")
library(rgdal, include.only = 'readOGR')
library(ggplot2)
setwd("")
source("boias.R")
source("ship.R")

# Buscar SHIP?
ship <- T
# Dados SHIP salvos:
endereco.ship <- NULL
# Também buscar dados de bóias?
boia <- T
# Dados de bóias salvos:
endereco.boia <- NULL

# Devolver em CSV, PNG, e/ou só visualizar imagem?
devolve.csv <- F
devolve.png <- T
abrir.imagem <- F
visao.geral <- F

# área para plotar
if(abrir.imagem || devolve.png){
  lats <- c(-40, 10)
  lons <- c(-50, 10)}

# lista de ID boias com lat e lon para plotar, caso dados de boia não sejam online
if(!(is.null(endereco.boia)))
{
  lista.de.boias <- data.frame()
}

# onde salvar?
saida <- "/dados"

# shapefiles de fundo
continentes <- readOGR(sprintf("%s/shapes", getwd()), layer = "ne_50m_coastline", verbose = F)

#####################################################################
graphics.off()

if(boia)
{
  # ainda vai verificar lista de boias online
  if(is.null(endereco.boia))
  {
    # buscar lista geral de boias
    local.boias <- procurar.boias(salvar.geral=FALSE)
    
    # quais boias estão na área desejada?
    boias.dentro <- local.boias[intersect(which(lats[2]>=local.boias$LAT & local.boias$LAT>=lats[1]),
                                          which(lons[2]>=local.boias$LON & local.boias$LON>=lons[1])),]
  }
  
  # buscar dados dessas boias que estão na área desejada
  obs.boias <- baixar.boias(lista.de.boias=boias.dentro)
  
  # if(visao.geral)
  # {
  #   # um dataframe pra mostrar as boias na visão geral
  #   v.g.b <- data.frame()
  # }
  
  cabecalho.boia <- c("YY","MM","DD","hh","mm","WDIR","WSPD","GST", "WVHT","DPD","APD","MWD","PRES","ATMP","WTMP",
                      "DEWP","VIS","PTDY","TIDE","LAT","LON", "ID")
  unidades.boia <- c("yr","mo","dy","hr","mn","degT","m/s","m/s", "m","sec","sec","degT","hPa","degC","degC",
                     "degC","nmi","hPa","ft","°","°", "ID")
  #names(unidades.boia) <- cabecalho.boia
  
  if(devolve.csv)
  {
    for(datas in unique(obs.boias$DD)){
      data <- paste( as.character(obs.boias[obs.boias$DD==datas,3][1]),
                     as.character(obs.boias[obs.boias$DD==datas,2][1]),
                     as.character(obs.boias[obs.boias$DD==datas,1][1]), sep = "-")
      
      print(sprintf("Foram obtidas %i observações de bóias do dia %s",
                    nrow(obs.boias[obs.boias$DD==datas, ]), data))
      write.csv(obs.boias[obs.boias$DD==datas,],
                file = sprintf("%s%s/BUOY_obs_em_%s.csv", getwd(), saida, data),
                row.names = F)
    }
    print(sprintf("Totalizando %i observações salvas em csv", nrow(obs.boias)))
  }
}

if(ship)
{
  cabecalho.ship <- c("SHIP_ID", "YY", "MM", "DD", "hh", "LAT", "LON", "WDIR", "WSPD", "GST", "WVHT",
                      "DPD", "APD", "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS", "PTDY", "TCC", "S1HT",
                      "S1PD", "S1DIR", "S2HT", "S2PD", "S2DIR", "II", "IE", "IR", "IC", "IS", "Ib", "ID", "Iz")
  unidades.ship <- c("(estacao)", "(ano)", "(mes)", "(dia)", "(hora)", "(°)", "(°)", "dir. vento(°T)", "vel. vento(m/s)",
                     "rajada(m/s)", "altura das ondas (m)", "período dominante da onda (s)", "período médio da onda (s)",
                     "direção média da onda (°T)", "pressão atmosférica (hPa)", "temperatura do ar (°C)",
                     "temperatura da superfície do mar (°C)", "temperatura do ponto de orvalho (°C)", "visibilidade (NM)",
                     "tendência de pressão (hPa)", "cobertura de nuvens (octa)",
                     "(m)", "(s)", "(°T)", "(m)", "(s)", "(°T)", "II", "IE", "IR", "IC", "IS", "Ib", "ID", "Iz")
  #names(unidades.ship) <- cabecalho.ship
  
  # puxar dados:
  obs.ship <- procurar.ship()
  
  if (ncol(obs.ship) != length(cabecalho.ship)){
    stop("Cabeçalho não confere com os dados!")
  }else{
    # colocar o cabeçalho no dataframe
    names(obs.ship) <- cabecalho.ship
  }
  
  if(devolve.csv){
    for(datas in unique(obs.ship$DD)){
      data <- paste( as.character(obs.ship[obs.ship$DD==datas,4][1]),
                     as.character(obs.ship[obs.ship$DD==datas,3][1]),
                     as.character(obs.ship[obs.ship$DD==datas,2][1]), sep = "-")
      
      print(sprintf("Foram obtidas %i obs.shipervações do dia %s",
                    nrow(obs.ship[obs.ship$DD==datas, ]), data))
      write.csv(obs.ship[obs.ship$DD==datas,],
                file = sprintf("%s%s/SHIP_obs.ship_em_%s.csv", getwd(), saida, data),
                row.names = F)
    }
    print(sprintf("Totalizando %i observações salvas em csv", nrow(obs.ship)))
  }
}
repeat{

  if(abrir.imagem || devolve.png){
    cat("Períodos disponíveis em SHIP:\n")
    for(AA in unique(obs.ship$YY)){
      cat(sprintf("Ano %i\n", AA))
      for(M in unique(obs.ship$MM)){
        cat(sprintf("Mês %i\n", M))
        for(dias in unique(obs.ship$DD))
        {
          cat(sprintf("\tDia %i\n", dias))
          cat("Horas: ")
          for (horas in unique(obs.ship[obs.ship$DD==dias,5])) {
            cat(sprintf("%i ", horas))
          }
          cat("\n")
        }
      }
    }

    if(!visao.geral)
    {
      repeat{
        ano <- ifelse(length(unique(obs.ship$YY))>1,
                             readline("Escolher ano: "),
                             unique(obs.ship$YY))
        if(ano %in% unique(obs.ship$YY)){break}
      }
      repeat{
        mes <- ifelse(length(unique(obs.ship$MM))>1,
                      readline("Escolher mês: "),
                      unique(obs.ship$MM))
        if(mes %in% unique(obs.ship$MM)){break}
      }
      repeat{
        dia <- readline("Escolher dia: ")
        if(dia %in% unique(obs.ship$DD)){break}
      }
      repeat{
        hora <- readline("Escolher hora: ")
        if(hora %in% unique(obs.ship[obs.ship$DD==dia,5])){break}
      }
    }
  
    # variável para plotar:
    for (OO in 8:21) {
      cat(cabecalho.ship[OO],"=",unidades.ship[OO],"\n")
    }
    repeat{
      qual.var <- readline("Escolher variável: ")
      if(qual.var %in% cabecalho.ship){break}
      #if(qual.var=="todas"){break}
    }
    
    if(!visao.geral){
      # só colunas com lat lon e variavel no dia e na hora certos
      selecao <- obs.ship[obs.ship$YY==ano & obs.ship$MM==mes & obs.ship$DD==dia & obs.ship$hh==hora, c("YY", "MM", "DD", "hh", "LAT", "LON", qual.var)]
      selecao.boias <- obs.boias[obs.boias$YY==ano & obs.boias$MM==mes & obs.boias$DD==dia & obs.boias$hh==hora, c("YY", "MM", "DD", "hh", "LAT", "LON", qual.var)]
    }else{
      selecao <- obs.ship[obs.ship$DD==dia & obs.ship$hh==hora, c("LAT", "LON")]
    }
    
    # COMPOSIÇÃO DA IMAGEM
    
    minha.imagem <- ggplot()+
      geom_path(data = continentes,
                aes(x = long, y = lat, group=group),
                size = 0.4)+
      geom_point(data = selecao,
                 colour = "blue",
                 size = 1.5,
                 aes(x = LON, y = LAT))+
      geom_point(data = selecao.boias,
                 colour = "yellow",
                 size = 1.5,
                 aes(x = LON, y = LAT))+
      {
          if(visao.geral)
          {
            geom_text(data = selecao,
                      aes(x = LON, y = LAT),
                      label = selecao$hh,
                      nudge_x = 1,
                      nudge_y = 0,
                      size = 2)
          }else{
            # usar um geom para certos IF(variavel a ser visualizada)
            geom_text(data = selecao,
                      aes(x = LON, y = LAT),
                      label = as.vector(selecao[qual.var])[[1]],
                      nudge_x = 0.05,
                      nudge_y = 0.75,
                      size = 4)
        }
      }+
      {
        if(boia&&(!visao.geral)){
          geom_text(data = selecao.boias,
                    aes(x = LON, y = LAT),
                    label = as.vector(selecao.boias[qual.var])[[1]],
                    nudge_x = 0.05,
                    nudge_y = 0.75,
                    size = 4)
        }
      }+
      coord_fixed(ratio = 27.5/25,
                  xlim = lons,
                  ylim = lats,
                  expand = FALSE)+
      labs(x = "Longitude (°)",
           y = "Latitude (°)")+
      theme_light()+
      {
        if(visao.geral)
        {
          ggtitle(sprintf("Horário de observações nos dias %s", paste(as.character(unique(obs.ship$DD)), collapse = ", ")))
        }else{
          # um título para cada variavel escolhida
          
          ggtitle(sprintf("Observações de %s às %s UTC de %s-%s-%s", unidades.ship[match(qual.var,cabecalho.ship)], hora, dia, mes, ano))
        }
      }
  }
  
  if(abrir.imagem){
    x11()
    print(minha.imagem)
  }
  
  if(devolve.png){
    png(file=sprintf("%s%s/OCEAN_OBS_%s_%sh_%s-%s-%s_.png", getwd(), saida, qual.var, hora, dia, mes, ano),
        res=300, width = 7.8, height = 7.7, units = "in")
    print(minha.imagem)
    graphics.off()
    cat("\t Imagem salva\n")
  }

  sair <- readline("Sair? (s/n):")
  if(sair=="s"){break}
}
