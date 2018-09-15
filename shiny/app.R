library(anytime)
library(shiny)
library(DBI)
library(pool)
library(dplyr)
library(tidyr)
library(plotly)
library(tidytext)

data("stop_words")
stop_words <- rbind(stop_words,
      data.frame(word = c("cat","cats"),
                 lexicon = "custom"))

pool <- dbPool(
        drv = RMySQL::MySQL(),
        dbname = "nss_db",
        host = "db",
        port = 3306,
        username = "root",
        password = "pwd"
)

ui <- fluidPage(

       # actionButton("button", "STOP!"),
        #plotlyOutput("popPlot"),
        plotlyOutput("sentPlot")
        
)

server <- function(input, output, session) {
        
        output$popPlot <- renderPlotly({

                data() %>% count(word, sort = TRUE) %>%
                        top_n(10) %>%
                plot_ly(y = .$word, 
                        x = .$n, 
                        type = 'bar', 
                        orientation = 'h')
        })
        
        output$sentPlot <- renderPlotly({
                
                data() %>% head(10000) %>%
                        inner_join(get_sentiments("bing")) %>%
                        count(index = as.POSIXct(round(timestamp, "mins")), sentiment) %>%
                        spread(sentiment, n, fill = 0) %>%
                        mutate(sentiment = positive - negative) %>%
                        plot_ly(x = .$index, 
                                y = .$sentiment, 
                                type = 'scatter',
                                mode = 'lines') %>%
                        layout(
                                yaxis = list(range = c(-20,20))
                        )
                
        })
        
        observe({
                
                plotlyProxy("popPlot", session) %>%
                        plotlyProxyInvoke("update")

                plotlyProxy("sentPlot", session) %>%
                        plotlyProxyInvoke("extendTraces",
                                          list(y=list(list(data()$sentiment))), list(0))
                
        })
        
        data <- reactivePoll(100, session,
                             # This function returns the latest timestamp from the DB
                             checkFunc = function() {
                                     pool %>% tbl("Messages") %>%
                                             summarise(max_time = max(timestamp, na.rm = TRUE)) %>%
                                             collect() %>%
                                             unlist()
                                     
                             },
                             # This function returns a data.frame ready for text mining
                             valueFunc = function() {
                                     pool %>% tbl("Messages") %>%
                                             filter(!data %like% "%RT%") %>%
                                             collect() %>%
                                             mutate(data = gsub('.*cats"','', data)) %>% 
                                             mutate(data = gsub("[^[:alnum:][:space:]]","",data)) %>%
                                             unnest_tokens(word, data) %>%
                                             anti_join(stop_words) %>% 
                                             mutate(timestamp = anytime(timestamp/1e+9))
                                             
                             }
        )
}

shinyApp(ui, server)



