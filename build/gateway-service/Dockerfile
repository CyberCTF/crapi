# Upstream's Dockerfile (app/Dockerfile, = services/gateway-service of OWASP/crAPI) with two
# changes: the sources are copied from app/, and certgen is pinned to v1.4.0 (upstream downloads
# the latest release). The certificate already names the host gateway-service.
FROM golang:1.21-bookworm AS builder
WORKDIR /app

COPY app/go.* ./
RUN go mod download

COPY app/ ./

# Build the binary.
RUN go build -v -o server

RUN wget https://github.com/minio/certgen/releases/download/v1.4.0/certgen-linux-amd64 -O /tmp/certgen \
    && chmod +x /tmp/certgen

RUN /tmp/certgen -host "127.0.0.1,gateway-service,api.mypremiumdealership.com,mypremiumdealership.com"
RUN ls -la

FROM debian:bookworm-slim
SHELL ["/bin/bash", "-c"]
WORKDIR /app

RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/server /app/server
COPY --from=builder /app/public.crt /app/server.crt
COPY --from=builder /app/private.key /app/server.key

EXPOSE 443

CMD ["/app/server"]
