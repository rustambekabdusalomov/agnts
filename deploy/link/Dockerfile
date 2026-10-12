# agnts-link: the connector a team runs inside its own network.
# Build from the repository root:
#   docker build -f deploy/link/Dockerfile -t agnts-link .
FROM golang:1.26-alpine AS build
WORKDIR /src/server
COPY server/go.mod server/go.sum ./
RUN go mod download
COPY server ./
ARG VERSION=dev
RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/agnts-link ./cmd/agnts-link

# No shell, non-root; the CA roots are there for the TLS connection to agnts.
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/agnts-link /usr/local/bin/agnts-link
USER nonroot
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/agnts-link"]
