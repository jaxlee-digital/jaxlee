# Jaxlee

Personal site. Photography, software, woodworking, 3D printing, writing.

## Local dev

```bash
bundle install
bundle exec jekyll serve
# http://127.0.0.1:4000/jaxlee/
```

## Structure

- `_posts/` — blog posts
- `_photography/`, `_software/`, `_woodworking/`, `_3dprinting/` — collection items
- `_layouts/`, `_includes/` — templates
- `assets/css/main.css` — styles
- `_data/nav.yml` — nav order
- `_config.yml` — site config (set `baseurl: ""` when a custom domain is attached)

## Deploy

GitHub Pages builds automatically from the `main` branch.

## New entry

Create a file in the appropriate collection folder:

```
---
title: "Piece title"
date: 2026-04-21
cover: /assets/images/piece-cover.jpg
---

Body in markdown.
```
