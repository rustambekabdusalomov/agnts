# syntax=docker/dockerfile:1

# Admin panel
FROM node:22-alpine AS admin
WORKDIR /src/apps/admin
COPY apps/admin/package.json apps/admin/package-lock.json ./
RUN npm ci
COPY shared /src/shared
COPY apps/admin ./
RUN npm run build

# Server
FROM golang:1.26-alpine AS server
WORKDIR /src/server
COPY server/go.mod server/go.sum ./
RUN go mod download
COPY server ./
ARG VERSION=dev
ARG COMMIT=unknown
RUN CGO_ENABLED=0 go build -trimpath \
      -ldflags "-s -w -X main.version=${VERSION} -X main.commit=${COMMIT}" \
      -o /out/hiro ./cmd/hiro \
 && mkdir -p /out/data

# Runtime: no shell, no package manager, non-root.
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=server /out/hiro /usr/local/bin/hiro
COPY --from=admin /src/apps/admin/dist /srv/web
COPY --from=server --chown=nonroot:nonroot /out/data /var/lib/hiro
ENV HIRO_WEB_DIR=/srv/web \
    HIRO_ADDR=:8080
EXPOSE 8080
USER nonroot
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s CMD ["/usr/local/bin/hiro", "healthcheck"]
ENTRYPOINT ["/usr/local/bin/hiro"]
CMD ["serve"]
