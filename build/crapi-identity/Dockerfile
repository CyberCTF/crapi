# Upstream's Dockerfile (app/Dockerfile, = services/identity of OWASP/crAPI) with two changes: the
# sources are copied from app/, and the environment of upstream's deploy/docker/docker-compose.yml
# is baked in (ENV at the end), except that API_GATEWAY_URL is https://gateway-service (upstream:
# https://api.mypremiumdealership.com, the gateway's container name, which is not a valid machine
# name here).
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


# Java Maven Build
FROM gradle:8.1-jdk17-focal AS gradlebuild
WORKDIR /app
COPY app/*.gradle.kts ./
COPY app/gradle.properties ./
# Only download dependencies
# Eat the expected build failure since no source code has been copied yet
RUN gradle clean build --no-daemon > /dev/null 2>&1 || true
COPY app/src src
RUN gradle build
RUN gradle bootJar

# Main Image
FROM eclipse-temurin:17-noble
# #Java
RUN apt -y update && apt -y install curl && apt -y clean
# RUN apt -y update && apt -y install wget curl unzip && apt -y clean
# RUN wget https://www.yourkit.com/download/docker/YourKit-JavaProfiler-2023.9-docker.zip -P /tmp/ && \
#   unzip /tmp/YourKit-JavaProfiler-2023.9-docker.zip -d /usr/local && \
#   rm /tmp/YourKit-JavaProfiler-2023.9-docker.zip
RUN mkdir /app
WORKDIR /app
COPY --from=gradlebuild /app/build/libs/identity-service-1.0-SNAPSHOT.jar /app/identity-service-1.0-SNAPSHOT.jar

ARG SERVER_PORT
EXPOSE ${SERVER_PORT}
EXPOSE 10001 8080 8989

ENV JAVA_TOOL_OPTIONS="-Xmx128m"

COPY app/jwks.json /app/default_jwks.json
COPY app/entrypoint.sh /entrypoint.sh
COPY app/health.sh /app/health.sh
CMD [ "/entrypoint.sh"]

# Environment of upstream's deploy/docker/docker-compose.yml
ENV LOG_LEVEL=INFO \
    DB_NAME=crapi \
    DB_USER=admin \
    DB_PASSWORD=crapisecretpassword \
    DB_HOST=postgresdb \
    DB_PORT=5432 \
    SERVER_PORT=8080 \
    ENABLE_SHELL_INJECTION=false \
    JWT_SECRET=crapi \
    MAILHOG_HOST=mailhog \
    MAILHOG_PORT=1025 \
    MAILHOG_DOMAIN=example.com \
    SMTP_HOST=smtp.example.com \
    SMTP_PORT=587 \
    SMTP_EMAIL=user@example.com \
    SMTP_PASS=xxxxxxxxxxxxxx \
    SMTP_FROM=no-reply@example.com \
    SMTP_AUTH=true \
    SMTP_STARTTLS=true \
    JWT_EXPIRATION=604800000 \
    ENABLE_LOG4J=false \
    API_GATEWAY_URL=https://gateway-service \
    TLS_ENABLED=false \
    TLS_KEYSTORE_TYPE=PKCS12 \
    TLS_KEYSTORE=classpath:certs/server.p12 \
    TLS_KEYSTORE_PASSWORD=passw0rd \
    TLS_KEY_PASSWORD=passw0rd \
    TLS_KEY_ALIAS=identity
