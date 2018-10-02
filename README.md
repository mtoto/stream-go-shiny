# Streaming Analytics Demo with NATS

This repo contains the assets to create a real-time Shiny app that visualizes tweets based on a certain keyword. Under the hood, we use 
the [Twitter Streaming API](https://developer.twitter.com/en/docs/tutorials/consuming-streaming-data.html) to access the tweets and [NATS Streaming](https://github.com/nats-io/go-nats-streaming) to process and write them to a MySQL database. The Shiny app queries this database continously to update the data in the dashboard. All the components are containerized can be deployed using Docker Compose. For more detail, see [my blogpost on this project](http://tamaszilagyi.com/blog/lightweight-streaming-analytics-with-nats/). The dashboard is currently live on http://stream.tamaszilagyi.com/.

## Getting started

You need to have Docker and Docker compose installed on your machine. To run the the service, clone the repo and build the containers. By default, the keyword to filter the Twitter Stream is "trump". You can change it by updating the `.env` file. 

```
git clone https://github.com/mtoto/stream-go-shiny.git
cd stream-go-shiny
docker-compose build
```

To start the service we run:

```
docker-compose -f docker-compose.yml up
```

It might take a couple of minutes for all the containers to be stand up. You can check `http://localhost/twitter` for the dashboard, it should look something like this:

![](https://media.giphy.com/media/7ELgP0jqdokVZXEpAf/giphy.gif)

