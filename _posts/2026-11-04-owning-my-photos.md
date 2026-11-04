---
title: "My Photos Live on My Drive Now"
date: 2026-11-04
last_updated: 2026-11-04
author: sheehan
tags: [software, self-hosting, privacy]
excerpt: "I set up Immich last night. My photos now live on my own drive instead of Apple's servers."
---

I set up Immich last night. It took a few hours. My photos are now backed up to an 18-terabyte drive sitting under my desk instead of Apple's servers in some data center I'll never see.

It wasn't complicated. That's the point.

---

For years I paid iCloud $3/month to store photos of my kid, my dogs, my family trips to the Bahamas. Apple holds them, Apple serves them, Apple decides what happens to them. If I stop paying, they go away. If Apple decides to change their terms, restructure their pricing, or just shut the product down: I find out when I get the email.

That's a weird arrangement when you think about it. These are my memories. I took them. They live on a server I don't own, managed by a company whose interests are not mine.

So I stopped.

---

**What I built:**

An old OptiPlex running Fedora, an 18 TB hard drive, and [Immich](https://immich.app), an open-source photo library that looks and works almost exactly like Google Photos. Face recognition, smart search, timeline view, mobile app with automatic backup. The whole thing.

My phone connects to it over my local network. When I'm at home, photos back up automatically over wifi. When I'm away, Tailscale gives me a private encrypted tunnel back to the house. Cloudflare sits in front of the public-facing piece — a subdomain I can share photo links from, handling SSL and caching.

The drive holds the photos. I hold it.

---

**Why this is better:**

No subscription. The drive cost money once. Immich is free. Tailscale has a free tier. Cloudflare has a free tier. The OptiPlex was already running.

No lock-in. Immich stores photos as regular files on disk — organized by date, in folders, exactly what you'd expect. If Immich disappeared tomorrow, the photos are still there. Point any other software at them.

No surprises. Apple can't raise my price. Google can't decide to scan my library for policy violations. Nobody is training a model on pictures of Jaxon.

The backup problem is also solved differently. iCloud is not a backup. It's a sync. If you delete a photo, it deletes everywhere. My drive is a real backup target: write once, stay there, nothing removes it unless I do.

---

**What it took:**

Honestly, an evening. The hard part was not Immich. It was the network setup. Port forwarding on an AT&T router has the worst UI I've ever encountered. But it works now, and I don't have to touch it again.

The software side is a few containers managed by systemd. Same pattern I use for Jellyfin, same pattern for the arr stack. It's become a comfortable way to run things: rootless Podman, Quadlet files, restart-on-failure. Set it and forget it.

---

This isn't a tutorial. It's just a note that this is possible, it's not that hard, and it's worth doing.

Your photos are yours. They should live somewhere you control.
