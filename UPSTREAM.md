# Upstream

| | |
| --- | --- |
| Project | OWASP crAPI |
| Repository | https://github.com/OWASP/crAPI |
| Version | v1.1.6 |
| Commit | 700f03d12a392d9e408260b4beae72ed02a4a1a4 |
| Licence | Apache-2.0 |

That commit is vendored unchanged, without its Git history, split so that each service sits in
the build folder of its machine:

| Upstream path | Here |
| --- | --- |
| `services/identity/` | `build/crapi-identity/app/` |
| `services/community/` | `build/crapi-community/app/` |
| `services/workshop/` | `build/crapi-workshop/app/` |
| `services/web/` | `build/crapi-web/app/` |
| `services/gateway-service/` | `build/gateway-service/app/` |
| `services/mailhog/` | `build/mailhog/app/` |
| everything else (docs, deploy, OpenAPI spec, Postman collections, `services/chatbot/`) | `app/` |

Each `build/<machine>/Dockerfile` is upstream's Dockerfile with the sources copied from `app/` and
the environment of upstream's `deploy/docker/docker-compose.yml` baked in; its header comment says
what else differs:

- the gateway's container name `api.mypremiumdealership.com` is not a valid machine name, so the
  gateway is `gateway-service` (a name its certificate already covers) and `API_GATEWAY_URL` is
  `https://gateway-service`;
- the chatbot (and its ChromaDB) is left out: it needs an OpenAI key and internet access. The web
  front end points its chatbot routes at an unused local port so nginx starts;
- pinned versions where upstream takes the latest: openresty `1.31.1.1-alpine`, certgen `v1.4.0`,
  MailHog `v1.0.1` (built with Go 1.26, since MailHog has no go.mod and its dependencies resolve
  to their latest versions);
- `build/postgresdb/` and `build/mongodb/` are the `postgres:14` and `mongo:4.4` services of that
  compose file with their environment baked in.

To update, replace the folders above with a newer release, then change these tables.
