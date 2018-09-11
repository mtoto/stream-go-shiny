package main

import (
	"fmt"
	"log"
	"net/http"
	"sync"

	nats "github.com/nats-io/go-nats"
	stan "github.com/nats-io/go-nats-streaming"
)

type server struct {
	nc stan.Conn
}

func main() {
	var s server

	natsClient, _ := stan.Connect("test-cluster", "test2", stan.NatsURL(nats.DefaultURL))
	s.nc = natsClient

	http.HandleFunc("/createTask", s.receiveTweets)
	fmt.Println("Server listening on port 8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}

}

func (s server) receiveTweets(w http.ResponseWriter, r *http.Request) {
	// Use a WaitGroup to wait for messages to arrive
	var wg sync.WaitGroup
	wg.Add(1)
	s.nc.Subscribe("tweets", func(msg *stan.Msg) {
		fmt.Fprintf(w, string(msg.Data))
	}, stan.DeliverAllAvailable())

	wg.Wait()
	s.nc.Close()
}
