# Usa la imagen base de R con Shiny preinstalado
FROM rocker/shiny-verse

# Copia tu aplicación Shiny en el contenedor
COPY . /srv/shiny-server/

# Expon el puerto 3838
EXPOSE 3838

# Inicia el servidor Shiny
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/', port = 3838, host = '0.0.0.0')"]

