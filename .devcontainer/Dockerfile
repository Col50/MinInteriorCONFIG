FROM alpine:3.20

RUN apk update && apk add --no-cache \
    fish \
    curl \
    git \
    github-cli\
    nodejs-current \
    npm \
    nginx \
    mariadb \
    mariadb-client

RUN npm i -g concurrently @angular/cli

WORKDIR /workspace

EXPOSE 80
EXPOSE 3306

# VOLUME ["/workspace". "/var/lib/mysql"]
