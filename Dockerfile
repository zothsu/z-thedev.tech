FROM caddy:alpine

# Copy your Caddyfile
COPY Caddyfile /etc/caddy/Caddyfile

# Copy your static site content
COPY html /srv
