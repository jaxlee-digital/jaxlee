---
title: "My Photos Live on My Drive Now"
date: 2026-11-04
last_updated: 2026-11-13
author: nova
co_authors: [sheehan]
tags: [software, self-hosting, privacy]
excerpt: "I set up Immich last night. My photos now live on my own drive instead of Apple's servers. This is the full project: Immich, Caddy, Cloudflare, and a static image CDN."
---

I set up Immich last night. It took a few hours. My photos are now backed up to an 18-terabyte drive sitting under my desk instead of Apple's servers in some data center I'll never see.

It wasn't complicated. That's the point.

---

For years I paid iCloud $3/month to store photos of my kid, my dogs, my family trips to the Bahamas. Apple holds them, Apple serves them, Apple decides what happens to them. If I stop paying, they go away. If Apple decides to change their terms, restructure their pricing, or just shut the product down: I find out when I get the email.

That's a weird arrangement when you think about it. These are my memories. I took them. They live on a server I don't own, managed by a company whose interests are not mine.

So I stopped.

---

**What I built**

The full stack, end to end:

- **[Immich](https://immich.app)** — open-source photo library running on an OptiPlex under my desk. Face recognition, smart search, timeline, mobile app with automatic backup. Looks and works like Google Photos, except I own it.
- **[Caddy](https://caddyserver.com)** — reverse proxy handling TLS automatically. Two virtual hosts: `photos.jaxleedigital.com` proxies to Immich, `img.jaxleedigital.com` serves static image files directly off disk for this site.
- **Cloudflare** — sits in front of both subdomains. Handles SSL termination for clients, caching, DDoS protection. Free tier covers everything.
- **Tailscale** — private encrypted tunnel back to the house when I'm away from the LAN. The phone app backs up over wifi at home; Tailscale handles the away case without exposing anything extra publicly.
- **18 TB drive** — the actual storage. Regular files on disk, organized by date. No proprietary format, no lock-in.

---

**The network layout**

```
Phone (home wifi)
  └── LAN → Immich (192.168.1.104:2283)

Phone (away, Tailscale)
  └── Tailscale → OptiPlex → Immich

Browser / jaxleedigital.com
  └── img.jaxleedigital.com
        └── Cloudflare (proxy + cache)
              └── Caddy → /mnt/media/photos/ (static files)

Immich web UI / sharing
  └── photos.jaxleedigital.com
        └── Cloudflare (proxy)
              └── Caddy → localhost:2283 (Immich)
```

Two separate subdomains, two separate purposes. `img.` is a static file server for the site. `photos.` is Immich. Keeping them split means the image CDN stays fast and cache-friendly without Immich's auth layer getting in the way.

---

**Why this is better**

No subscription. The drive cost money once. Immich is free. Tailscale has a free tier. Cloudflare has a free tier. The OptiPlex was already running.

No lock-in. Immich stores photos as regular files on disk — organized by date, in folders, exactly what you'd expect. If Immich disappeared tomorrow, the photos are still there. Point any other software at them.

No surprises. Apple can't raise my price. Google can't decide to scan my library for policy violations. Nobody is training a model on pictures of Jaxon.

The backup problem is also solved differently. iCloud is not a backup. It's a sync. If you delete a photo, it deletes everywhere. My drive is a real backup target: write once, stay there, nothing removes it unless I do.

---

**What it took**

Honestly, an evening. The hard part was not Immich. It was the network setup. Port forwarding on an AT&T router has the worst UI I've ever encountered. But it works now, and I don't have to touch it again.

The software side is a few containers managed by systemd. Same pattern I use for Jellyfin, same pattern for the arr stack. Rootless Podman, Quadlet files, restart-on-failure. Set it and forget it.

The Caddy config is two blocks and about 20 lines total. See [the follow-up post](/field-notes/2026/11/caddy-immich-reverse-proxy/) for the exact setup.

---

This isn't a tutorial. It's just a note that this is possible, it's not that hard, and it's worth doing.

Your photos are yours. They should live somewhere you control.
