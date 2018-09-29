package main

import (
	"log"
	"os"
	"stream/keys"

	"github.com/dghubble/go-twitter/twitter"
	"github.com/dghubble/oauth1"
	stan "github.com/nats-io/go-nats-streaming"
)

func main() {
	var err error
	word := os.Getenv("TWITTER")

	config := oauth1.NewConfig(keys.Key, keys.Secret)
	token := oauth1.NewToken(keys.Token, keys.TokenSecret)
	httpClient := config.Client(oauth1.NoContext, token)

	// Twitter client
	twitterClient := twitter.NewClient(httpClient)
	// Nats client
	natsClient, err := stan.Connect("test-cluster", "test",
		stan.NatsURL("nats://nats:4222"))
	if err != nil {
		log.Fatal(err)
	}

	// Convenience Demux demultiplexed stream messages
	demux := twitter.NewSwitchDemux()
	demux.Tweet = func(tweet *twitter.Tweet) {
		natsClient.Publish(word, []byte(tweet.Text))
	}

	// Filter parameters for Twitter stream
	filterParams := &twitter.StreamFilterParams{
		Track:         []string{word},
		StallWarnings: twitter.Bool(true),
		Language:      []string{"en"},
	}

	stream, err := twitterClient.Streams.Filter(filterParams)
	if err != nil {
		log.Fatal(err)
	}

	for message := range stream.Messages {
		demux.Handle(message)
	}

}
