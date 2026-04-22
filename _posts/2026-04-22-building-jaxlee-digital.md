---
title: "Building jaxlee digital"
date: 2026-04-22
author: sheehan
co_authors: [nova]
tags: [meta, brand, jekyll, infra]
excerpt: "Bringing the site in line with a brand I've been shaping for a while."
---

I've been building toward this brand for a while. The palette, the
logo, the way the workspace looks, the way my prints come out. All
of it deliberate, chosen piece by piece. Warm cream, rose-gold,
near-black ink. Soft edges. The `{ }` motif that nods to the
developer work without making it the whole story.

What I'd been missing was the site. I had a Squarespace at
[sheehan.club](https://sheehan.club) that served its purpose. It's
where my real-name professional presence lives. But it was never
going to be the creative home. Squarespace has its own visual
gravity and I wanted the design to be mine.

## The stack

Jekyll, GitHub Pages, no custom workflows. The posts are markdown
in a git repo. Pages builds for free inside its plugin whitelist.
Collections for photography, software, craft, résumés. One CSS
file. No JavaScript.

Push to `main`, Pages rebuilds, site goes live. That's the whole
pipeline.

Plain text in a folder is worth more than any CMS feature. If
GitHub Pages disappears tomorrow, the site is still a folder I
can read.

Nova (my AI assistant, running Claude inside OpenClaw) scaffolded
the Jekyll site and ported the old Squarespace content based on
my direction. I set the architecture, made the design decisions,
and reviewed the output. She did the file moving.

## The design system

ChatGPT drew the logo. I gave it the palette, the motifs, and the
feel I wanted. The visual language had been sitting in my head for
a while before I asked for a mark to anchor it.

The colors came out of that same direction. `#DB997C` rose-gold,
`#FCF2E8` warm cream, `#25262C` near-black. Poppins for display,
Urbanist for body. The same colors I print in, work at, and live
with. Dropping them into CSS variables was less "picking a palette"
and more wiring up the one I already use.

Every color on the site references a variable. No inline hex. If
I want to adjust the accent, it's one line.

## Porting

From sheehan.club I kept what still fit. Bio, consulting pitch,
sailing CV, two old posts, the photography gallery. The Squarespace
placeholder pages ("News", "Technical Blog", "Videos") that I'd
never filled in got left behind. Letting those go was the actual
migration.

## Positioning

For about an hour I called the site *"a field notebook for finished
things."* I liked the discipline it implied. Only write up completed
work. Then I sat with it and realized a notebook is exactly where
you don't only keep finished things. A notebook is where the messy
parts live too.

Softened it to:

> **A field notebook.**

Scope stays open. Posts can be polished or rough. The rule isn't
*only finished*, it's *only when I feel like it*.

## What's next

Attach `jaxlee.com`. Wire up Mastodon. Start actually posting.

The last one is the real project.
