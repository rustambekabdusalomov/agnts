# OpenVPN sidecar: one container per workspace on OpenVPN, started by agnts
# (never by hand). It runs the workspace's client config in its own network
# namespace (the only container with NET_ADMIN and /dev/net/tun) and lets
# the gateway in through SOCKS5. The agnts binary is static, so it runs here.
#   docker compose --profile build build ovpn
ARG AGNTS_IMAGE=agnts:local
FROM ${AGNTS_IMAGE} AS agnts

FROM alpine:3.22
RUN apk add --no-cache openvpn iproute2
COPY --from=agnts /usr/local/bin/agnts /usr/local/bin/agnts
ENTRYPOINT ["/usr/local/bin/agnts", "ovpn-sidecar"]
