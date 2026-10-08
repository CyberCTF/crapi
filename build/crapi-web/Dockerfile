# Upstream's Dockerfile (app/Dockerfile, = services/web of OWASP/crAPI) with three changes: the
# sources are copied from app/, the openresty base is pinned to 1.31.1.1-alpine (upstream:
# alpine), and the environment of upstream's deploy/docker/docker-compose.yml is baked in (ENV at
# the end), except that CHATBOT_SERVICE is 127.0.0.1:5002 (upstream: crapi-chatbot:5002): the
# chatbot needs an OpenAI key and internet access, so it is not part of this lab, and nginx needs
# a resolvable address to start; the chatbot routes answer 502.
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


# Node build
FROM node:20 AS build
RUN mkdir /app
WORKDIR /app
COPY app/*.json /app/
RUN npm install --silent
COPY app/src /app/src
COPY app/public /app/public
RUN cp ./src/config.js.template ./src/config.js
RUN NODE_OPTIONS=--max_old_space_size=4096 npm run build
RUN ls /app/build

# Main Image
FROM openresty/openresty:1.31.1.1-alpine
RUN apk add gettext curl
# React
RUN rm /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
COPY app/nginx-wrapper.sh /etc/nginx/nginx-wrapper.sh
COPY app/nginx.conf.template /etc/nginx/conf.d/default.conf.template
COPY app/nginx.ssl.conf.template /etc/nginx/conf.d/default.ssl.conf.template
RUN mkdir -p /app
COPY app/certs /app/certs
RUN echo "daemon off;" >> /usr/local/openresty/nginx/conf/nginx.conf
EXPOSE 80
EXPOSE 443

CMD [ "/etc/nginx/nginx-wrapper.sh" ]

# Environment of upstream's deploy/docker/docker-compose.yml
ENV COMMUNITY_SERVICE=crapi-community:8087 \
    IDENTITY_SERVICE=crapi-identity:8080 \
    WORKSHOP_SERVICE=crapi-workshop:8000 \
    CHATBOT_SERVICE=127.0.0.1:5002 \
    MAILHOG_WEB_SERVICE=mailhog:8025 \
    TLS_ENABLED=false
