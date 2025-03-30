# Docker Server Project

This project outlines the steps taken to create a hardened, self-hosted Docker server running on a Linode VPS. It includes setup and deployment of a secure web server with HTTPS using Caddy and Let's Encrypt.

## Overview
The goal of this project is to create a reproducible, secure, and minimal Docker-based environment to serve static or containerized web content. Caddy is used as the primary web server due to its automatic HTTPS features.

## Project Structure
```
~/docker.zthedev.com/
├── html/                # Static site content
│   └── index.html
├── Caddyfile            # Configuration for Caddy server
└── docker-compose.yml   # Service definitions
```

## Key Features
- Hardened non-root user with SSH key-based access
- Intrusion prevention using Fail2Ban with custom jail configuration
- Automated security updates for the base system
- Periodic system health and security audits with Lynis
- Read-only and restricted-capability Docker container setup
- Persistent and securely configured Docker volumes
- Automatic HTTPS provisioning with Caddy and Let's Encrypt

## Technologies Used
- Linode (VPS)
- Caddy (Server)
- Docker
- Docker Compose
- NGINX (in container)
- Fail2Ban
- Lynis
- Ubuntu 24.04 LTS
- Let's Encrypt (via Caddy)

## How to Use
1. Provision a VPS (Linode used in this case)
2. Set up your SSH key and secure the server
3. Install Docker and Docker Compose
4. Clone this repository and customize `index.html`, `Caddyfile`, and `docker-compose.yml`
5. Run `docker-compose up -d` to launch your secure site

## Security
- Docker container permissions locked down with `cap_drop`, `read_only`, and proper volume setup
- Caddy handles TLS certificate issuance and renewal
- Periodic system audits with Lynis

## Notes
- DNS must point to your VPS IP before TLS provisioning
- Snapshot the server regularly before major changes
- For dynamic apps, extend this setup with environment-specific containers

## TODO / Future Improvements
- [ ] Re-enable and configure IPv6 support with firewall and Fail2Ban rules
- [ ] Set up automated backups for site content and Docker volumes
- [ ] Add CI/CD pipeline for content or container deployment via GitHub Actions

> For a detailed daily breakdown, refer to the (dockerServerSetupJournal.md)[Docker Server Setup] in this repo.

