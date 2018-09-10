// based on: https://dzone.com/articles/docker-compose-nats-microservices-development-made
package main

import (
	"fmt"
	"sync"

	nats "github.com/nats-io/go-nats"
	stan "github.com/nats-io/go-nats-streaming"
)

func main() {
	natsClient, _ := stan.Connect("test-cluster", "test2", stan.NatsURL(nats.DefaultURL))
	// Use a WaitGroup to wait for a message to arrive
	wg := sync.WaitGroup{}
	wg.Add(1)

	natsClient.Subscribe("tweets1", func(msg *stan.Msg) {
		//wg.Done()
		fmt.Printf("Received a message: %s\n", string(msg.Data))
	}, stan.DurableName("resumeTweets"))

	wg.Wait()
	natsClient.Close()

}
