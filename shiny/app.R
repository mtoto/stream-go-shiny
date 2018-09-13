library(shiny)
library(DBI)
library(pool)
library(dplyr)
library(plotly)
data("stop_words")
stop_words <- rbind(stop_words,
      data.frame(word = c("cat","cats"),
                 lexicon = "custom"))

pool <- dbPool(
        drv = RMySQL::MySQL(),
        dbname = "nss_db",
        host = "localhost",
        port = 3306,
        username = "tamas",
        password = "kabbe"
)

ui <- fluidPage(

       # actionButton("button", "STOP!"),
        plotlyOutput("popPlot")
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
        
        observe({
                
                plotlyProxy("popPlot", session) %>%
                        plotlyProxyInvoke("update")
                
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
                                             anti_join(stop_words)
                                             
                             }
        )
}

shinyApp(ui, server)



