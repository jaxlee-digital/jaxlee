---
title: "Building jaxlee digital"
date: 2026-04-22
last_updated: 2026-05-19
author: sheehan
co_authors: [nova]
tags: [meta, brand, jekyll, infra]
excerpt: "Why I moved off Squarespace and rebuilt my creative home as a pile of markdown files."
---

I moved my creative work off Squarespace this week. New home: Jekyll,
GitHub Pages, markdown in a repo. Push to `main` and it rebuilds.
No CMS, no Action, no JavaScript.

sheehan.club is still up. That one's my real-name professional
presence. This is the creative side.

Part of the move was wanting the design to be mine, but the bigger
part was wanting to actually own the content. In Squarespace, my
words live in their database, rendered by their templates, at their
mercy, and I pay rent for the privilege. Here, every post is a plain
markdown file in a git repo I control. If GitHub Pages disappears
tomorrow, I still have the folder. If I want to move to a different
static generator in five years, I copy the files over. The content
outlives the platform.

It also kills a subscription. I'm working on reducing those
generally. Squarespace was an easy one to cut.

Nova, my AI assistant (Claude running inside OpenClaw), did the
scaffolding and the porting. I set the architecture and made the
design calls. She did the file moving.

## Colors

The logo came first. ChatGPT drew it.

Everything on the site references a CSS variable. No inline hex.

## What I kept, what I dropped

From the old site: bio, consulting pitch, sailing CV, two old
posts, the photography gallery. Kept.

The Squarespace template pages I'd never filled in. News.
Technical blog. Videos. Gone.

The migration was mostly the dropping.

## What's next

Attach `jaxlee.com`. Wire up Mastodon. Post things.

The last one is the hard part.
