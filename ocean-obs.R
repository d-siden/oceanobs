# obter (e exibir, opcional) dados em código SHIP e boias
# https://www.ndbc.noaa.gov/ship_obs.php?uom=M&time=12
# https://www.ndbc.noaa.gov/
# https://www.dataquest.io/blog/web-scraping-in-r-rvest/
# Acessar o site
con <- url('https://www.ndbc.noaa.gov/ship_obs.php?uom=M&time=0')

linhas <- readLines(con)
