# WORKFLOW: jaxlee-site

Operating manual for Sheehan's personal site at
`jaxlee-digital.github.io/jaxlee`. Read this first before
publishing or deploying anything to this repo.

## TL;DR

- **Repo:** `jaxlee-digital/jaxlee` (GitHub)
- **Local path:** `~/.openclaw/workspace/jaxlee-site/` — its **own
  git repo**, nested inside the workspace. Use
  `git -C /home/sheehan/.openclaw/workspace/jaxlee-site …` for
  every git command (see `skills/git-safe-commit/`).
- **Live:** https://jaxleedigital.com
- **Engine:** Jekyll via `github-pages` gem, default-branch build
- **Theme:** custom (in-repo)
- **Custom domain:** `jaxleedigital.com` (Cloudflare DNS, nameservers moved from Squarespace 2026-11-04)
- **Image CDN:** `https://img.jaxleedigital.com` — Nginx/Immich on OptiPlex, Cloudflare proxied. Photos live at `/mnt/media/photos/`. Use for all new post images instead of committing to repo.
- **Baseurl:** `` (blank — custom domain active)
- **Identity:** `jaxlee-digital` GitHub account (separate from
  Sheehan's primary), per-repo credential helper
  `/home/sheehan/.openclaw/bin/git-credential-jaxlee`

Full background: `infra/jaxlee-site/README.md`.

## Common jobs

| Job | Skill / section |
|---|---|
| Publish a blog post | `skills/jekyll-publish-post/` |
| Edit a layout, asset, or `_config.yml` | edit → preview → screenshot → approve → push (`skills/jekyll-deploy/`) |
| Add resume / log entry / project | Draft → review → promote → push, same as posts |
| Update `llms.txt` | `skills/agentic-browsing/` (not shipped yet here) |
| Audit accessibility | `skills/a11y-audit/` |
| Shoot preview screenshots | `skills/jekyll-screenshot-preview/` |

This site has collections beyond `_posts/`: `_resumes`, `_log`,
and a `_drafts/`. Same approval flow as posts — draft, review,
promote, push.

## Local preview

See `skills/jekyll-podman-preview/` for the full recipe. Variables
for this site:

```bash
SITE_SLUG="jaxlee"
SITE_PATH="/home/sheehan/.openclaw/workspace/jaxlee-site"
PORT="4001"
BASEURL="/jaxlee"
EXTRA_FLAGS=""          # set to "--drafts" to include _drafts/
```

Browse at `http://localhost:4001/jaxlee/`.

Port 4001 (not 4000) so jaxlee and oceanspray previews can run
simultaneously without colliding. If you only ever run one at a
time, either port works.

## Accessibility & standards

**WCAG 2.2 AA on everything user-facing.** Full checklist:
`jaxlee-site/AGENT.md` "Accessibility & standards" — that file is
the canonical reference for *both* sites. Audit tool:
`skills/a11y-audit/`.

Run the audit before any deploy that touches templates, layouts,
or new pages. Skip for routine posts that reuse existing
components.

## Authorship guidelines

All content has an author and optional co-authors. Use handles defined in `_data/authors.yml`.

**When Nova drafts the post:**
- `author: nova` + `co_authors: [sheehan]`
- Byline renders: "By Nova ✨ with Sheehan Commette"
- AI disclosure note auto-renders via byline include

**When Sheehan writes, Nova edits/assists:**
- `author: sheehan` + `co_authors: [nova]`
- Byline renders: "By Sheehan Commette with Nova ✨"

**When Sheehan writes solo:**
- `author: sheehan` only

Examples:
- `_posts/2026-11-04-owning-my-photos.md` — Nova primary, Sheehan co-author
- `_log/2026-09-11-green-turtle-cay.md` — Nova primary, Sheehan co-author
- `_posts/2026-04-22-building-jaxlee-digital.md` — Sheehan primary, Nova co-author

## Image hosting

New post images go on the image CDN, not committed to the repo:

1. Copy image to `/mnt/media/photos/posts/<slug>/` on the OptiPlex
2. Reference as `https://img.jaxleedigital.com/photos/posts/<slug>/filename.jpg`
3. Only commit images to `assets/` for legacy posts or if the CDN is unavailable

The CDN is Nginx served from the 18.2 TB drive, proxied through Cloudflare.

## Log entries (`_log/`)

Use `_log/` for travel, outings, and place-based entries. Key front matter:

```yaml
title: "Place Name"
date: YYYY-MM-DD
last_updated: YYYY-MM-DD
author: nova          # or sheehan
co_authors: [sheehan] # or [nova]
location: "City, State/Country"
cover: https://img.jaxleedigital.com/photos/posts/<slug>/hero.jpg
lat: 00.0000
lng: -00.0000
excerpt: "One line."
facts:
  - label: "Key"
    value: "Value"
```

For multi-year/recurring places, use inline `<h2 id="YYYY">` headings in the body with a jump nav at the top:
```html
<p><strong>Jump to:</strong> <a href="#2026">2026</a> · <a href="#2023">2023</a></p>
```

## Repo-specific rules

- **`baseurl` is blank** (custom domain active). Do not add `/jaxlee`.
- **Internal links** use `{{ site.baseurl }}/path/` or `relative_url` filter.
- **GitHub Pages plugins only.** Allowed: `jekyll-feed`,
  `jekyll-seo-tag`, `jekyll-sitemap`, `jekyll-paginate`.
- **No `.github/workflows/`.** Pages builds directly from the
  default branch. Don't add Actions unless deliberately moving
  off the default-branch build.

## Approval gate

- Drafts only until approved. Finished work only.
- **Send desktop + tablet + mobile screenshots** with every visual
  change. Helper + viewports: `skills/jekyll-screenshot-preview/`
  (set `SITE_SLUG="jaxlee"` and `URL_BASE="http://localhost:4000/jaxlee"`).
- Acceptable approval phrases: "publish it", "ship it",
  "promote to post", "looks good, push". Ambiguous → ask.

## Where things live

- `_posts/` — published posts
- `_drafts/` — drafts (not built unless `--drafts`).
  **Gitignored.** Drafts are local-only WIP; only `_posts/` ships.
- `_layouts/` — page templates
- `_includes/` — partial templates
- `_sass/` — styles
- `_scripts/` — site automations
- `assets/` — images, CSS output, JS
- `_resumes/`, `_log/`, `photography/`, `software/`,
  `sailing.md`, `work.md`, `writing/` — collection content
- `AGENT.md` — color palette + the canonical Accessibility &
  standards checklist used by both sites
- `_config.yml` — site config

## Verify deploy

See `skills/jekyll-deploy/`. Quick site-specific checks:

```bash
curl -sI https://jaxlee-digital.github.io/jaxlee/ | head -5
curl -s https://jaxlee-digital.github.io/jaxlee/sitemap.xml | grep -m1 lastmod
```

## Related

- `infra/jaxlee-site/README.md` — full infra notes
- `AGENT.md` — accessibility checklist, palette, layout/include conventions
- `skills/jekyll-publish-post/SKILL.md`
- `skills/jekyll-deploy/SKILL.md`
- `skills/git-safe-commit/SKILL.md`
- `skills/jekyll-screenshot-preview/SKILL.md`
- `skills/a11y-audit/SKILL.md`
- `skills/agentic-browsing/SKILL.md`
