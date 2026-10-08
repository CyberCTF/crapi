# Upstream's Dockerfile (app/Dockerfile, = services/community of OWASP/crAPI) with two changes:
# the sources are copied from app/, and the environment of upstream's
# deploy/docker/docker-compose.yml is baked in (ENV at the end).
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# GoLang Build
FROM golang:1.21-alpine AS builder
ENV GO111MODULE=on \
    CGO_ENABLED=0
WORKDIR /build
COPY app/go.mod .
COPY app/go.sum .
RUN go mod download
COPY app/main.go ./main.go
COPY app/api ./api
RUN go mod vendor
RUN ls -al
RUN go build -o main .
RUN go test -v ./...
WORKDIR /dist
RUN cp /build/main .

# Main Image
FROM alpine:3

# go
WORKDIR /app
RUN apk update && apk add --no-cache curl
COPY --from=builder /dist/main /app/main
COPY app/certs /app/certs
COPY app/health.sh /app/health.sh
RUN ls -al /app

ARG SERVER_PORT
EXPOSE ${SERVER_PORT}
# Expose profiling port
EXPOSE 6060
CMD /app/main

# Environment of upstream's deploy/docker/docker-compose.yml
ENV LOG_LEVEL=INFO \
    IDENTITY_SERVICE=crapi-identity:8080 \
    DB_NAME=crapi \
    DB_USER=admin \
    DB_PASSWORD=crapisecretpassword \
    DB_HOST=postgresdb \
    DB_PORT=5432 \
    SERVER_PORT=8087 \
    MONGO_DB_HOST=mongodb \
    MONGO_DB_PORT=27017 \
    MONGO_DB_USER=admin \
    MONGO_DB_PASSWORD=crapisecretpassword \
    MONGO_DB_NAME=crapi \
    TLS_ENABLED=false \
    TLS_CERTIFICATE=certs/server.crt \
    TLS_KEY=certs/server.key
