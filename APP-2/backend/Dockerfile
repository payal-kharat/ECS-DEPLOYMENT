# syntax=docker/dockerfile:1.4
FROM golang:1.18-alpine AS builder
WORKDIR /code

ENV CGO_ENABLED 0
ENV GOPATH /go
ENV GOCACHE /go-build

COPY go.mod go.sum ./
RUN  go mod download

COPY . .

RUN go build -o bin/backend main.go

CMD ["/code/bin/backend"]

