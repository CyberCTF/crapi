#!/bin/sh
# A seeded user (adam007@example.com) logs in through the web front end and gets a token, then
# reads its dashboard: identity, PostgreSQL and the web proxy work together.
token=$(curl -fsS -H 'Content-Type: application/json' \
  -d '{"email":"adam007@example.com","password":"adam007!123"}' \
  http://crapi-web/identity/api/auth/login | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
[ -n "$token" ] || exit 1
curl -fsS -H "Authorization: Bearer $token" http://crapi-web/identity/api/v2/user/dashboard | grep -q adam007
