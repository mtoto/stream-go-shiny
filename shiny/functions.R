df <- df %>% mutate(timestamp1 = anytime(timestamp/1e+9))

# sentiment minute barplot
df_bar <- df %>%  tail( 100) %>%
        inner_join(get_sentiments("bing")) %>%
        mutate(value = 1) %>%
        group_by(timestamp1, sentiment) %>%
        summarise(values = sum(value)) %>%
        spread(sentiment, values, fill = 0) 

        plot_ly(x = df_bar$timestamp1, 
                y = df_bar$negative, 
                type = 'bar',
                name = 'Negative words') %>%
        add_trace(y = df_bar$positive, name = 'Positive Words') %>%
        layout(yaxis = list(title = 'Count'), barmode = 'stack')
        

# sentiment line plot
df %>%  head( 1000) %>%
        inner_join(get_sentiments("bing")) %>%
        count(index = timestamp1, sentiment) %>%
        spread(sentiment, n, fill = 0) %>%
        mutate(sentiment = positive - negative) %>%
        plot_ly(x = .$index, 
                y = .$sentiment, 
                type = 'scatter',
                mode = 'lines') %>%
        layout(
                yaxis = list(range = c(-5,5))
        )


        
