# obter (e exibir, opcional) dados em código SHIP e boias

# https://www.ndbc.noaa.gov/ship_obs.php?uom=M&time=12

# lembrar de setar o pwd no terminal para documents

# Trouxe a ferramenta?
for (p in c("stringr")){
  if (!(p %in% installed.packages())){
    install.packages(p)
  }
  library(p, character.only = T)
}

# Adentrar o recinto
recinto <- url('https://www.ndbc.noaa.gov/ship_obs.php?uom=M&time=0')

# Observar o ambiente
recinto <- readLines(recinto)
recinto <- data.frame(recinto)

# Separar os elementos
for (elemento in recinto$recinto) {
  # Procurar o título
  if (grepl("SHIP", elemento, fixed = T) ){
    print(elemento)
    cat("
    ")
  }
  # pegar centesimo elemento por razões
  # dividir pela \
  strsplit(recinto$recinto[100], split = "\"")
  # que fazer com os subelementos?
  
  
}