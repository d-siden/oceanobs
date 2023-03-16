# listar boias disponiveis online, retornar em dataframe com localização e ID, opcional salvar em .RData
procurar.boias <- function(salvar.geral=FALSE)
{
  endereco="https://www.ndbc.noaa.gov/data/stations/station_table.txt"
  
  # verificar existencia do endereço
  if(!(RCurl::url.exists(endereco))){stop("\tSem acesso à tabela de bóias\n")}
  
  # lista de boias/estações disponíveis
  estacoes <- read.table(file = endereco,
                         col.names=c("STATION_ID","OWNER","TTYPE","HULL","NAME",
                                     "PAYLOAD","LOCATION","TIMEZONE","FORECAST","NOTE"),
                         sep = "|",
                         header = F,
                         quote = "",
                         dec = ".",
                         strip.white = T,
                         fill = T,
                         comment.char = "#",
                         stringsAsFactors = F)
  
  # criar dataframe com colunas de ID, lat e lon
  lats <- c()
  lons <- c()
  # extrair localizacao de cada uma
  for(LL in 1:length(estacoes$LOCATION))
  {
    lats <- append(lats, ifelse(strsplit(estacoes$LOCATION[LL], split = " ")[[1]][2]=="S",
                                -as.numeric(strsplit(estacoes$LOCATION[LL], split = " ")[[1]][1]),
                                as.numeric(strsplit(estacoes$LOCATION[LL], split = " ")[[1]][1])))
    lons <- append(lons, ifelse(strsplit(estacoes$LOCATION[LL], split = " ")[[1]][4]=="W",
                                -as.numeric(strsplit(estacoes$LOCATION[LL], split = " ")[[1]][3]),
                                as.numeric(strsplit(estacoes$LOCATION[LL], split = " ")[[1]][3])))
  }
  
  resumo.estacoes <- data.frame("ID"=estacoes$STATION_ID,
                                "LAT"=lats,
                                "LON"=lons)
  # salvar arquivo original com a lista de boias
  if(salvar.geral)
  {
    save(estacoes, file = "boias.RData")
    cat("\tMetadados das boias foram salvos em arquivo RData")
  }
  
  return(resumo.estacoes)
}
##############################################################################################################
##############################################################################################################

# buscar dados de determinadas boias cujos números de ID, latitude e longitude vêm num dataframe
baixar.boias <- function(lista.de.boias, endereco=NULL)
{
  if(paste(names(lista.de.boias), collapse = ";")!="ID;LAT;LON"){stop("\tCabeçalho deve ser: ID  LAT  LON\n")}
  
  # se endereço de arquivo for não for fornecido, buscar na NOAA, caso contrário, carregar arquivo
  if(is.null(endereco))
  {
    # buscar e guardar dados dessas boias
    obs.boias <- data.frame()
    
    for (BB in lista.de.boias$ID)
    {
      # ver se os dados existem
      if(!(RCurl::url.exists(sprintf('https://www.ndbc.noaa.gov/data/realtime2/%s.txt', BB))))
      {
        cat("\tSem dados da bóia", BB,"\n")
        next
      }
      obs.boias <- rbind(obs.boias,
                         obs.boias <- read.table(
                           url(sprintf('https://www.ndbc.noaa.gov/data/realtime2/%s.txt', BB)),
                           header = F,
                           comment.char = "#",
                           col.names = c("YY","MM","DD","hh","mm","WDIR","WSPD","GST","WVHT","DPD",
                                         "APD","MWD","PRES","ATMP","WTMP","DEWP","VIS","PTDY","TIDE","LAT","LON", "ID"),
                           dec = ".",
                           fill = T,
                           skipNul = F,
                           na.strings = "MM",
                           stringsAsFactors = F))
      # não esquecer de colar as colunas com lat e lon que não vêm no site
      for (LLL in 1:nrow(obs.boias))
      {
        # quando está faltando lat e lon na linha, preencher
        if(is.na(obs.boias$LAT[LLL]))
        {
          obs.boias$LAT[LLL] <- lista.de.boias[lista.de.boias$ID==BB,"LAT"]
          obs.boias$LON[LLL] <- lista.de.boias[lista.de.boias$ID==BB,"LON"]
          obs.boias$ID[LLL] <- lista.de.boias[lista.de.boias$ID==BB,"ID"]
        }
      }
    }
  }else{
    #carregar arquivo
    obs.boias <- read.csv(file = endereco,
                          header = 1,
                          comment.char = "#",
                          col.names = c("YY","MM","DD","hh","mm","WDIR","WSPD","GST","WVHT","DPD",
                                        "APD","MWD","PRES","ATMP","WTMP","DEWP","VIS","PTDY","TIDE","LAT","LON", "ID"),
                          dec = ".",
                          fill = T,
                          skipNul = F,
                          stringsAsFactors = F)
  }
  
  return(obs.boias)
}

