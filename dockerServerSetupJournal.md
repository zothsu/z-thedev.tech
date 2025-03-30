# Docker Server Setup

A breakdown of setting up and hardening a Docker server from scratch, culminating in serving a static site securely with HTTPS using Caddy and Let's Encrypt.

---

## 2025-03-29 — DigitalOcean + SSH Setup

### What I Did
- Launched a VPS on DigitalOcean.
- Assigned a static IP.
- Added SSH key manually.
- Created user `***`.
- Locked down root SSH access.
- Configured UFW firewall (allowing SSH only from current IP).
- Ran into complications with IPv6 access — decided to skip for now.

### Problems
- IPv6 access wasn't working (SSH via IPv6 wouldn't connect).
- Fail2ban failed to start due to duplicate `[sshd]` jail entries.
- Fixed by removing extra jail definition in `jail.local`.

### Security Steps Completed
- SSH hardened.
- Fail2ban set up and functional.
- Initial Lynis audit completed.
- TODO added: revisit IPv6 security rules.

---

## 2025-03-30 — Linode Rebuild + Docker + HTTPS

### What I Did
- Moved to Linode due to DigitalOcean limitations.
- Renamed host to `***-dev`.
- Created fresh user and gave `sudo` permissions.
- Copied SSH key and secured permissions.
- Locked down UFW firewall, allowing for VPN use.
- Set up `fail2ban` properly with correct syntax.
- Ran full Lynis audit and reviewed security recommendations.
- Installed Docker and `docker-compose` (manual binary method).
- Created a test site using `nginx:alpine`.
- Replaced NGINX with Caddy for HTTPS.
- Updated Hostinger DNS to use `A` records (removed conflicting CNAME).
- Wrote `Caddyfile` to serve `z-thedev.tech` + `www.z-thedev.tech`.
- Ran `docker-compose up -d` — Caddy auto-issued TLS certificates.
- Took snapshot: `ready-for-dns`.

### Security Steps
- Applied SSH hardening per Lynis suggestions.
- Disabled root login, set SSH banner.
- Installed audit tools: `auditd`, `acct`, and log rotation.
- Ensured unattended security updates were enabled.
- Docker volume with proper permissions created for NGINX cache.

### Problems
- Fail2ban wouldn’t start due to malformed config (typo in `systemd` spelling).
- Docker permissions required adding user to `docker` group.
- Docker volume mounts had permission issues — fixed via manual `chown`.
- Orphaned NGINX containers caused network errors:
  ```bash
  docker stop dockerzthedevcom_web_1
  docker rm dockerzthedevcom_web_1
  docker network rm dockerzthedevcom_default
  ```
- TLS warnings in Caddy logs were just part of provisioning — resolved by waiting.

### Final Setup
```bash
~/docker.zthedev.com/
├── html/
│   └── index.html
├── Caddyfile
└── docker-compose.yml
```

### `Caddyfile`:
```caddyfile
z-thedev.tech, www.z-thedev.tech {
    root * /srv
    file_server
}
```

### `docker-compose.yml`:
```yaml
version: '3.9'

services:
  caddy:
    image: caddy:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./html:/srv:ro
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    restart: unless-stopped

volumes:
  caddy_data:
  caddy_config:
```

