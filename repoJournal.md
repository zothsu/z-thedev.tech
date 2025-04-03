# DevOps Project Journal — z-thedev.tech

---

## 2025-03-29 — DigitalOcean + SSH Setup

### What I Did
- Launched a VPS on DigitalOcean
- Assigned a static IP
- Added SSH key manually
- Created user `***`
- Locked down root SSH access
- Configured UFW firewall (allowing SSH only from current IP)
- Ran into complications with IPv6 access — decided to skip for now

### Problems
- IPv6 SSH access not working
- `fail2ban` failed to start due to duplicate `[sshd]` entries
- Fixed by removing extra jail definition in `jail.local`

### Security Steps Completed
- SSH hardened
- `fail2ban` functional
- Initial Lynis audit complete
- TODO: Revisit IPv6 security rules

---

## 2025-03-30 — Linode Rebuild + Docker + HTTPS

### What I Did
- Migrated from DigitalOcean to Linode
- Renamed host to `***-dev`
- Created new user with `sudo` access
- Added SSH key and secured permissions
- Locked down UFW (allow VPN only)
- Reinstalled `fail2ban` with correct syntax
- Ran full Lynis audit and reviewed results
- Installed Docker + `docker-compose` (manual binary method)
- Created test site with `nginx:alpine`
- Swapped to Caddy for HTTPS support
- Updated DNS via Hostinger (`A` records only)
- Wrote `Caddyfile` for `z-thedev.tech` and `www.z-thedev.tech`
- Ran `docker-compose up -d` — Caddy issued TLS certs
- Took snapshot: `ready-for-dns`

### Security Enhancements
- SSH hardening per Lynis suggestions
- Root login disabled, SSH banner set
- Installed: `auditd`, `acct`, and configured log rotation
- Enabled automatic security updates
- Configured Docker volume permissions for NGINX cache

### Problems
- `fail2ban` failed due to typo in `systemd`
- Had to add user to `docker` group
- Docker volume permissions — fixed via `chown`
- Orphaned containers caused network errors:
  ```bash
  docker stop dockerzthedevcom_web_1
  docker rm dockerzthedevcom_web_1
  docker network rm dockerzthedevcom_default
  ```
- Caddy’s TLS warnings were temporary — resolved by waiting

### Final Project Structure
```bash
~/docker.zthedev.com/
├── html/
│   └── index.html
├── Caddyfile
└── docker-compose.yml
```

### Caddyfile
```caddyfile
z-thedev.tech, www.z-thedev.tech {
    root * /srv
    file_server
}
```

### docker-compose.yml
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

---

## 2025-03-31 — Docker CI/CD Setup + GitHub Integration

### What I Did

#### 1. Cleaned Docker Environment
- Shut down containers: `docker-compose down`
- Removed orphaned volumes and networks
- Verified Docker health and cleaned up assets

#### 2. Updated Docker Image & Repository
- Built and tagged image: `zthdev/mycaddy:latest`
- Logged into Docker Hub (fixed username issue)
- Pushed image to Docker Hub

#### 3. Prepared GitHub Repo
- Confirmed files:
  - `Dockerfile`
  - `docker-compose.yml`
  - `Caddyfile`
  - `html/`
- All committed to GitHub repo: `z-thedev.tech`

#### 4. Created GitHub Actions Workflow
- Added `.github/workflows/build-and-deploy.yml`
- Steps:
  - Build Docker image
  - Push to Docker Hub
- Stored secrets:
  - `DOCKER_USERNAME`
  - `DOCKER_PASSWORD`

#### 5. Troubleshooting Login Issues
- Error: `incorrect username or password`
- Moved secrets to top-level GitHub Secrets
- Retested — login worked

### Next Steps
- Confirm successful workflow run (build + push)
- Automate server container pull and redeploy on push

---

## 2025-04-03 — Troubleshooting Deployment Pipeline

### Goal
Get automatic deployment via GitHub Actions + Docker + Appleboy SSH working.

### What Went Well
- CI pipeline builds image on push to `main`
- Image auto-pushes to Docker Hub
- SSH works manually via terminal
- Pipeline logic is solid and structured

### Main Issue
SSH handshake fails in GitHub Action:
```text
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain
```

### What I Tried
- Verified SSH key format and encoding
- Recreated key using:
  ```bash
  ssh-keygen -t ed25519
  ```
- Confirmed public key added to server
- Verified private key is correctly stored in GitHub Secrets
- Tried both raw and base64-encoded formats
- Set `debug: true` on Appleboy’s action
- Used `ssh -v` locally — no problems

### Suspicions
- GitHub Secrets might mishandle multiline keys
- Appleboy Action may not parse ED25519 keys correctly without extra formatting

### Wins
- Built & published Docker image
- Manual SSH access confirmed
- CI logic ready and working

### Still To Solve
- Fix Appleboy SSH key parsing in GitHub Actions
- Complete push-to-deploy automation


