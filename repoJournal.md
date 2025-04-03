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

## Summary for 2025-03-31: Docker CI/CD Setup and GitHub Integration

### What We Did:

#### 1. **Cleaned Up Docker Volumes and Containers**
- Shut down running containers using `docker-compose down`
- Removed orphaned or stuck volumes and networks
- Verified Docker status and cleared unused assets

#### 2. **Updated Docker Image & Repository**
- Built Docker image with tag: `zthdev/mycaddy:latest`
- Logged in to Docker Hub and fixed access issues (used correct username)
- Successfully pushed image to Docker Hub

#### 3. **Prepared Project Repository**
- Reviewed project files:
  - `Dockerfile`
  - `docker-compose.yml`
  - `Caddyfile`
  - `html/`
- Ensured everything was committed to a GitHub repo named `z-thedev.tech`

#### 4. **Created GitHub Actions Workflow**
- Added `.github/workflows/build-and-deploy.yml`
- Defined steps for building Docker image and pushing to Docker Hub
- Stored DockerHub credentials as GitHub Secrets:
  - `DOCKER_USERNAME`
  - `DOCKER_PASSWORD`

#### 5. **Troubleshooting Login Issues**
- Encountered error: `incorrect username or password`
- Moved secrets out of `env` block to top-level GitHub repo secrets
- Retested login and confirmed credentials were saved correctly

### What’s Left:
- Confirm successful workflow run (build + push)
- Automate container redeployment or pull new image on your server

---

### Notes:
- Your Docker image is ready and tested locally.
- GitHub repo is linked and secrets are securely stored.
- CI pipeline is configured and almost complete.

## Journal Entry – April 3, 2025

Title: Troubleshooting the Pipeline: SSH, Docker, and Deployment Woes

Today was all about fine-tuning my GitHub Actions workflow for automatic deployment using Docker and Appleboy’s SSH action.

I started by setting up a Docker-based CI/CD pipeline that builds my mycaddy image and pushes it to Docker Hub when I push to the main branch. Then, the appleboy/ssh-action was supposed to SSH into my server and run docker compose pull && up -d to update the website.

Things were going smoothly until… the error.

I hit an authentication failure on the Appleboy SSH step. Manual SSH login worked just fine, but the GitHub Action kept throwing:

ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain

That led me down a rabbit hole of debugging:
	•	Verified my SSH key format
	•	Recreated my key using ssh-keygen -t ed25519
	•	Ensured the public key was onthe server under the right user

Made sure the private key was correctly formatted and stored in GitHub Secrets

Tried both raw and base64-encoded key variants

Used the debug: true flag in the Action for more insight

Even ran a manual SSH session with -v to confirm everything worked locally

Despite all of this, the action still failed at the handshake. It’s a bit of a mystery, but I’m narrowing it down—suspecting GitHub's handling of multi-line secrets or key parsing quirks in Appleboy’s action.

### Wins

Built a working Docker image

Pushed to Docker Hub automatically

Validated manual SSH access

Cleaned and structured the pipeline logic

### Still To Solve

Appleboy SSH key parsing issue

Full deployment on push trigger

All in all, a good day of detective work in DevOps land.

