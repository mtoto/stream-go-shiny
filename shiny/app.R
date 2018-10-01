library(anytime)
library(shiny)
library(shinydashboard)
library(DBI)
library(pool)
library(dplyr)
library(tidyr)
library(tidytext)
library(ggplot2)

data("stop_words")
stop_words <- rbind(stop_words,
      data.frame(word = Sys.getenv("TWITTER"),
                 lexicon = "custom"))

pool <- dbPool(
        drv = RMySQL::MySQL(),
        dbname = "nss_db",
        host = "db", 
        port = 3306,
        username = "nss",
        password = "password" 
)

ui <- dashboardPage(
        dashboardHeader(title = "Twitter Sentiment Dashboard"),
        dashboardSidebar(disable = TRUE),
        dashboardBody(
        tags$style(type="text/css", ".recalculating {opacity: 1.0;}"), # https://github.com/rstudio/shiny/issues/1591
        
        fluidRow(
                box(plotOutput("timePlot"), width = 12)),
        
        fluidRow(
                box(plotOutput("sentPlot"), width = 12)), 
        
        fluidRow(
                box(plotOutput("topPos"), width = 6),
                box(plotOutput("topNeg"), width = 6))
                )
)

server <- function(input, output, session) {
        
        output$topPos <- renderPlot({
                
                data() %>% filter(sentiment == "positive") %>%
                        count(index = word, sentiment) %>% 
                        top_n(5) %>%
                        arrange(-n) %>%
                        ggplot(aes(x = reorder(index, n), y = n)) +
                        geom_bar(stat = "identity", fill = "#56B4E9")  +
                        coord_flip() +
                        theme_classic(base_size = 22) +
                        theme(legend.position="bottom") +
                        labs(x = NULL, y = NULL) +
                        ggtitle("TOP POSITIVE WORDS")
                
        })
        
        output$topNeg <- renderPlot({
                
                data() %>% filter(sentiment == "negative") %>%
                        count(index = word, sentiment) %>% 
                        top_n(5) %>%
                        arrange(-n) %>%
                        ggplot(aes(x = reorder(index, n), y = n)) +
                        geom_bar(stat = "identity", fill = "#E69F00")  +
                        coord_flip() +
                        theme_classic(base_size = 22) +
                        theme(legend.position="bottom") +
                        labs(x = NULL, y = NULL) +
                        ggtitle("TOP NEGATIVE WORDS")
                
        })
        
        output$sentPlot <- renderPlot({
                
                data() %>% count(index = as.POSIXct(round(timestamp, "mins")), sentiment) %>%
                        ggplot(aes(x = index, y = n, fill = sentiment)) +
                        geom_bar(position = "fill", stat = "identity") +
                        scale_y_continuous(labels = scales::percent) +
                        theme_classic(base_size = 22) +
                        theme(legend.position="bottom") +
                        labs(x = NULL, y = NULL) +
                        scale_fill_manual(values=c("#E69F00", "#56B4E9"))
                
                
        })
                
        output$timePlot <- renderPlot({
                
                data() %>% group_by(index = as.POSIXct(round(timestamp, "mins"))) %>%
                        summarise(tally = n_distinct(seq)) %>%
                        ggplot(aes(x = index, y = tally)) +
                        geom_bar(stat = "identity") +
                        geom_line() +
                        geom_point() +
                        theme_classic(base_size = 22) +
                        scale_fill_manual(values="#999999") +
                        labs(x = "time") +
                        ggtitle("TWEETS PER MINUTE") 
                
                
        })
        
        data <- reactivePoll(1000, session,
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
                                             filter(!data %like% "%http%") %>% 
                                             arrange(-timestamp) %>%
                                             head(1000) %>%
                                             collect() %>%
                                             mutate(data = gsub("[^[:alnum:][:space:]]","",data)) %>%
                                             unnest_tokens(word, data) %>%
                                             anti_join(stop_words) %>% 
                                             mutate(timestamp = anytime(timestamp/1e+9)) %>%
                                             inner_join(get_sentiments("bing")) 
                                   
                             }
        )
}

shinyApp(ui, server)


