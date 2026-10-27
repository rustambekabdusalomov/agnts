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
# agnts-muse is a sibling module (server/go.mod replaces it with
# ../../agnts-muse): pass it as a named context,
#   docker build --build-context agnts-muse=../agnts-muse .
COPY --from=agnts-muse . /agnts-muse
WORKDIR /src/server
COPY server/go.mod server/go.sum ./
RUN go mod download
COPY server ./
ARG VERSION=dev
ARG COMMIT=unknown
RUN CGO_ENABLED=0 go build -trimpath \
      -ldflags "-s -w -X main.version=${VERSION} -X main.commit=${COMMIT}" \
      -o /out/agnts ./cmd/agnts \
 && CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -o /out/agnts-guard ./cmd/agnts-guard \
 && mkdir -p /out/data

# Runtime: no shell, no package manager, non-root.
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=server /out/agnts /usr/local/bin/agnts
# agnts-guard runs inside the run containers (copied in by the runner).
COPY --from=server /out/agnts-guard /usr/local/bin/agnts-guard
COPY --from=admin /src/apps/admin/dist /srv/web
COPY --from=server --chown=nonroot:nonroot /out/data /var/lib/agnts
ENV AGNTS_WEB_DIR=/srv/web \
    AGNTS_ADDR=:8080
EXPOSE 8080
USER nonroot
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s CMD ["/usr/local/bin/agnts", "healthcheck"]
ENTRYPOINT ["/usr/local/bin/agnts"]
CMD ["serve"]
