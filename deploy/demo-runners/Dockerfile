FROM golang:1.26-alpine AS build
WORKDIR /src
COPY go.mod main.go ./
RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -o /demo-runners .

FROM scratch
COPY --from=build /demo-runners /demo-runners
ENTRYPOINT ["/demo-runners"]
