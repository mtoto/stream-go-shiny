# example: https://gist.github.com/wallyqs/7f72efdc3fd6371364f8b28cbe32c5ee
FROM golang:latest
WORKDIR /go/

COPY . /go

RUN go get -u github.com/dghubble/go-twitter/twitter && \
    go get -u github.com/dghubble/oauth1 && \
    go get -u github.com/nats-io/go-nats-streaming

COPY keys/ /go/src/stream/keys
RUN go build main.go

EXPOSE 8080
ENTRYPOINT ["/go/main"]