# OWASP crAPI

[OWASP crAPI](https://github.com/OWASP/crAPI) (completely ridiculous API) by the OWASP crAPI
contributors: a vulnerable car-owner platform built as microservices to teach the OWASP API
Security Top 10. This repository runs it with [Isoloom](https://www.isoloom.com):
[`isoloom.yml`](isoloom.yml) describes the machines, and every service builds from the vendored
upstream source with its own Dockerfile and the environment of upstream's compose file baked in.

| Machine | Service |
| --- | --- |
| crapi-web | Web front end and API proxy (nginx) on port 80, published on 8888 (HTTPS 443 on 8443) |
| crapi-identity | Identity service (Java, Spring Boot) on port 8080 |
| crapi-community | Community service (Go) on port 8087 |
| crapi-workshop | Workshop service (Python, Django) on port 8000 |
| gateway-service | Payment gateway (Go) on port 443 |
| mailhog | MailHog: SMTP on 1025, mail UI on 8025 |
| postgresdb | PostgreSQL 14 on port 5432 |
| mongodb | MongoDB 4.4 on port 27017 |

## Run it

```bash
isoloom generate
isoloom up docker
```

Then open http://localhost:8888/ and sign up with an `@example.com` address; mails (OTPs, vehicle
details) arrive in MailHog at http://localhost:8025/. The LLM chatbot of upstream is not included
(it needs an OpenAI key). The same spec runs as Docker on a local VM (`docker-vm`), on a cloud VM
(`cloud-docker`) or on Kubernetes. Lab guide: [challenges](app/docs/challenges.md) (solutions in
[challengeSolutions.md](app/docs/challengeSolutions.md)).

Upstream version and commit: [UPSTREAM.md](UPSTREAM.md).

## Licence

Apache-2.0, as crAPI ([LICENSE](LICENSE)). This application is deliberately vulnerable: keep it
isolated.
