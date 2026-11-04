FROM golang:1.26-alpine AS build
WORKDIR /src
COPY go.mod *.go ./
COPY traces ./traces
RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -o /demo-runners .

FROM scratch
# The runners read the repositories' files from GitHub over HTTPS.
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /demo-runners /demo-runners
ENTRYPOINT ["/demo-runners"]
