# Upstream's Dockerfile (app/Dockerfile, = services/mailhog of OWASP/crAPI) with these changes:
# the Go image is pinned to golang:1.26-alpine (upstream: golang:alpine) and MailHog to v1.0.1
# (upstream: @latest, which is v1.0.1). MailHog v1.0.1 has no go.mod, so its dependencies still
# resolve to their latest versions (golang.org/x/crypto now needs Go 1.26); the environment and user of upstream's
# deploy/docker/docker-compose.yml are baked in (MailHog stores mail in the mongodb machine, and
# runs as root there).
FROM golang:1.26-alpine AS builder

# Install MailHog:
RUN apk --no-cache add --virtual build-dependencies \
    git \
  && mkdir -p /root/gocode \
  && export GOPATH=/root/gocode \
  && go install github.com/mailhog/MailHog@v1.0.1

FROM alpine:3
# Add mailhog user/group with uid/gid 1000.
# This is a workaround for boot2docker issue #581, see
# https://github.com/boot2docker/boot2docker/issues/581
RUN adduser -D -u 1000 mailhog

COPY --from=builder /root/gocode/bin/MailHog /usr/local/bin/

USER mailhog

WORKDIR /home/mailhog

ENTRYPOINT ["MailHog"]

# Expose the SMTP and HTTP ports:
EXPOSE 1025 8025

# Environment and user of upstream's deploy/docker/docker-compose.yml
USER root
ENV MH_MONGO_URI=admin:crapisecretpassword@mongodb:27017 \
    MH_STORAGE=mongodb
