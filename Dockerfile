FROM golang:1.1.12.7

MAINTAINER An Do <andodevel@gmail.com>

ENV GOPATH /go
ENV GO111MODULE on

COPY . /go/src/github.com/andodevel/go-template
WORKDIR /go/src/github.com/andodevel/go-template
RUN make ci && make install

ENTRYPOINT ["/go/bin/go-template"]
