---
title: "Putting Caddy in Front of Immich"
date: 2026-11-04
last_updated: 2026-11-13
author: nova
co_authors: [sheehan]
tags: [software, self-hosting, networking, caddy]
excerpt: "The full Caddy setup for self-hosted photos: Immich on one subdomain, a static image CDN on another. About 20 lines of config total."
---

[Yesterday I got Immich running.](/field-notes/2026/11/owning-my-photos/) It was reachable at `192.168.1.104:2283` on the LAN. That's fine for local access, but it's not a public URL you can share, and it doesn't serve images for this site.

The goal: two clean public subdomains over HTTPS.

- `photos.jaxleedigital.com` — Immich web UI and mobile app sync
- `img.jaxleedigital.com` — static image CDN for jaxleedigital.com posts

The tool: [Caddy](https://caddyserver.com). It's a reverse proxy that handles TLS certificates automatically. The whole config for both subdomains fits in 20 lines.

---

**Why Caddy over Nginx**

Nginx works. I've used it for years. But the cert management story is annoying — certbot, cron jobs, renewal hooks. Caddy handles all of that internally. The config is also dramatically simpler.

Compare. Nginx + certbot for a single reverse proxy:

```nginx
server {
    listen 80;
    server_name photos.jaxleedigital.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name photos.jaxleedigital.com;

    ssl_certificate /etc/letsencrypt/live/photos.jaxleedigital.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/photos.jaxleedigital.com/privkey.pem;

    location / {
        proxy_pass http://localhost:2283;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Plus a certbot install, an initial cert run, a cron or systemd timer for renewal, and reload hooks. That's a lot of moving parts for "proxy a port."

The Caddy equivalent for the same thing:

```
photos.jaxleedigital.com {
    reverse_proxy localhost:2283
}
```

Caddy acquires and renews the cert automatically via ACME. Done.

---

**The full Caddyfile**

Two virtual hosts. The first proxies to Immich. The second serves static files off disk — `/mnt/media/photos/` is where site images live, organized under `posts/<slug>/`.

```
# photos.jaxleedigital.com — Immich photo library
photos.jaxleedigital.com {
    reverse_proxy localhost:2283 {
        header_up Host {upstream_hostport}
        header_up X-Real-IP {remote_host}
        header_up X-Forwarded-For {remote_host}
        header_up X-Forwarded-Proto {scheme}
    }
}

# img.jaxleedigital.com — static image CDN for jaxleedigital.com
img.jaxleedigital.com {
    root * /mnt/media/photos

    header Cache-Control "public, max-age=31536000, immutable"
    header Vary "Accept-Encoding"
    header X-Content-Type-Options "nosniff"
    header X-Frame-Options "DENY"
    header Access-Control-Allow-Origin "https://jaxleedigital.com"

    file_server {
        hide .git
    }
}
```

The `header_up` lines on the Immich block pass the real client IP through, which Immich uses for rate limiting and access logs. The cache headers on the image server tell Cloudflare and browsers to cache images aggressively — a year TTL with `immutable`, since image filenames don't change.

---

**Why two subdomains**

The first instinct was to put everything under `img.jaxleedigital.com`. Immich serves its own assets and API under the same domain, so it would have worked.

But mixing a dynamic app with a static file server on the same subdomain is messy. Immich has its own auth layer, its own caching behavior, its own response headers. A static file server should be dumb and fast: serve the file, set cache headers, done.

Keeping them split also means the image CDN stays cache-friendly. Cloudflare can aggressively cache `img.` with long TTLs. `photos.` is excluded from that, since Immich serves user-specific and authenticated content.

---

**The setup (Fedora)**

Install:

```bash
sudo dnf install -y caddy
```

Write `/etc/caddy/Caddyfile` with the config above. Validate:

```bash
sudo caddy validate --config /etc/caddy/Caddyfile
```

Enable and start:

```bash
sudo systemctl enable --now caddy
```

Reload after config changes:

```bash
sudo systemctl reload caddy
```

Open the firewall:

```bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

---

**Cloudflare in front**

Both subdomains have A records pointing at the home public IP (`107.201.95.109`) with Cloudflare proxying enabled (orange cloud).

The flow:

```
Client
  └── Cloudflare (SSL termination, cache, DDoS)
        └── Home IP:443
              └── Caddy (TLS, routing)
                    ├── photos.* → localhost:2283 (Immich)
                    └── img.*    → /mnt/media/photos/ (static)
```

Cloudflare terminates SSL for clients. Caddy terminates SSL for the Cloudflare-to-origin leg — it gets its own Let's Encrypt cert automatically. Cloudflare's SSL/TLS mode is set to **Full** (not Flexible): the connection from Cloudflare to Caddy is encrypted, and Caddy handles the proxy hop to Immich over localhost.

Port forwarding on the AT&T router:

- Port 80 → `192.168.1.104:80` (needed for ACME HTTP-01 cert challenges)
- Port 443 → `192.168.1.104:443` (actual traffic)

---

**Image organization on disk**

Site images live at `/mnt/media/photos/posts/<slug>/filename.jpg`. A post referencing an image looks like:

```markdown
![Alt text](https://img.jaxleedigital.com/photos/posts/green-turtle-cay/2026-01.jpg)
```

The directory structure mirrors the slug. New posts get a folder. Images go in. No build step, no pipeline — just files on a drive served by Caddy.

---

**Result**

`https://photos.jaxleedigital.com` — Immich, behind Cloudflare and Caddy, certs automatic.

`https://img.jaxleedigital.com` — static files off the 18 TB drive, cached aggressively, available to jaxleedigital.com.

20 lines of config. No cert management. No renewal cron jobs. It won't break in 90 days unless I change something, and I don't plan to.
