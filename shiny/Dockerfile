FROM rocker/shiny

RUN apt-get update && apt-get install -y libssl-dev \
    default-libmysqlclient-dev \
    && apt-get clean \ 
    && rm -rf /var/lib/apt/lists/ \ 
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## install packages from CRAN (and clean up)
RUN install2.r DBI pool dplyr tidyr ggplot2 tidytext RMySQL anytime shinydashboard

## put shiny app is in build folder /twitter
COPY ./app.R /srv/shiny-server/twitter/

## updated config file
COPY ./shiny-server.conf /etc/shiny-server/shiny-server.conf

## revamped shell script to share env with shiny app
COPY ./shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]

