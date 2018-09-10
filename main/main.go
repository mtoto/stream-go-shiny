package main

import (
	"log"
	"stream/keys"

	"github.com/dghubble/go-twitter/twitter"
	"github.com/dghubble/oauth1"
	nats "github.com/nats-io/go-nats"
	stan "github.com/nats-io/go-nats-streaming"
)

func main() {

	config := oauth1.NewConfig(keys.Key, keys.Secret)
	token := oauth1.NewToken(keys.Token, keys.TokenSecret)
	httpClient := config.Client(oauth1.NoContext, token)

	// Twitter client
	client := twitter.NewClient(httpClient)
	// Nats client
	natsClient, _ := stan.Connect("test-cluster", "test", stan.NatsURL(nats.DefaultURL))

	// Convenience Demux demultiplexed stream messages
	demux := twitter.NewSwitchDemux()
	demux.Tweet = func(tweet *twitter.Tweet) {
		//fmt.Printf(string(msg))
		natsClient.Publish("tweets1", []byte(tweet.Text))
	}

	// FILTER
	filterParams := &twitter.StreamFilterParams{
		Track:         []string{"#USOpen"},
		StallWarnings: twitter.Bool(true),
	}

	stream, err := client.Streams.Filter(filterParams)
	if err != nil {
		log.Fatal(err)
	}

	for message := range stream.Messages {
		demux.Handle(message)
	}

}
