# Upstream's Dockerfile (app/Dockerfile, = services/workshop of OWASP/crAPI) with two changes: the
# sources are copied from app/, and the environment of upstream's deploy/docker/docker-compose.yml
# is baked in (ENV at the end), except that API_GATEWAY_URL is https://gateway-service (upstream:
# https://api.mypremiumdealership.com, the gateway's container name, which is not a valid machine
# name here).
#
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


FROM python:3.11-alpine AS build
# Not using alpine based on suggestion
# https://pythonspeed.com/articles/alpine-docker-python/

# Python
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache  gettext curl py3-pip postgresql-dev
RUN apk add --update --no-cache --virtual .build-deps \
        python3-dev openssl-dev \
        libffi-dev gcc py3-pip \
        python3-dev \
        musl-dev \
        libffi-dev

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
RUN mkdir /app
WORKDIR /app
COPY app/ /app
RUN pip install wheel && pip wheel . --wheel-dir /app/wheels

FROM python:3.11-alpine
COPY --from=build /app /app
WORKDIR /app
RUN apk update && apk add --no-cache postgresql-libs curl
RUN pip install --no-index --find-links=/app/wheels -r requirements.txt
COPY app/certs /app/certs
COPY app/health.sh /app/health.sh
ARG SERVER_PORT
EXPOSE ${SERVER_PORT}
CMD ["/app/runner.sh"]

# Environment of upstream's deploy/docker/docker-compose.yml
ENV LOG_LEVEL=INFO \
    IDENTITY_SERVICE=crapi-identity:8080 \
    DB_NAME=crapi \
    DB_USER=admin \
    DB_PASSWORD=crapisecretpassword \
    DB_HOST=postgresdb \
    DB_PORT=5432 \
    SERVER_PORT=8000 \
    MONGO_DB_HOST=mongodb \
    MONGO_DB_PORT=27017 \
    MONGO_DB_USER=admin \
    MONGO_DB_PASSWORD=crapisecretpassword \
    MONGO_DB_NAME=crapi \
    SECRET_KEY=crapi \
    API_GATEWAY_URL=https://gateway-service \
    TLS_ENABLED=false \
    TLS_CERTIFICATE=certs/server.crt \
    TLS_KEY=certs/server.key \
    FILES_LIMIT=1000
