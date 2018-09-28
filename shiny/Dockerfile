FROM rocker/shiny

RUN apt-get update && apt-get install -y libssl-dev \
    default-libmysqlclient-dev \
    && apt-get clean \ 
    && rm -rf /var/lib/apt/lists/ \ 
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## install packages from CRAN (and clean up)
RUN install2.r DBI pool dplyr tidyr plotly tidytext RMySQL anytime 

## assume shiny app is in build folder /twitter
COPY ./app.R /srv/shiny-server/twitter/

## updated config file
COPY ./shiny-server.conf /etc/shiny-server/shiny-server.conf