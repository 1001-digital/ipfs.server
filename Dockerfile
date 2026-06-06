FROM caddy:2-alpine AS caddy

FROM ipfs/kubo:v0.41.0
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY config/Caddyfile /etc/caddy/Caddyfile
COPY config/container-init.d/ /container-init.d/
