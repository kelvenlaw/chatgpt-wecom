# Step 1: Modules caching
FROM golang:1.19 AS base

# Move to working directory /build
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

# Step 2: Builder
FROM golang:1.19 as builder

ENV GO111MODULE=on \
    CGO_ENABLED=1

COPY --from=base /go/pkg /go/pkg
COPY . /app
WORKDIR /app
RUN go build -ldflags '-linkmode external -extldflags "-static"' -o /bin/chatgpt-wecom ./cmd/app

# Step 3: Final
FROM alpine:latest
WORKDIR /home/works/program
COPY ./conf/chatgpt.conf ./conf/chatgpt.conf
COPY --from=builder /bin/chatgpt-wecom .

EXPOSE 80
CMD ["./chatgpt-wecom", "-conf=conf/chatgpt.conf"]