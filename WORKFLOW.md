# WORKFLOW: jaxlee-site

Operating manual for Sheehan's personal site at
`jaxlee-digital.github.io/jaxlee`. Read this first before
publishing or deploying anything to this repo.

## TL;DR

- **Repo:** `jaxlee-digital/jaxlee` (GitHub)
- **Local path:** `~/.openclaw/workspace/jaxlee-site/` — this is
  its **own git repo**, nested inside the workspace but not part
  of the workspace repo. **Always target it explicitly with `git
  -C /home/sheehan/.openclaw/workspace/jaxlee-site …`.** `cd` does
  not persist across exec calls in the OpenClaw gateway, so `cd`
  + `git status` will silently run against the workspace repo
  and miss this site's changes.
- **Live:** https://jaxlee-digital.github.io/jaxlee
- **Engine:** Jekyll via `github-pages` gem, default-branch build
- **Theme:** custom (in-repo)
- **Custom domain:** none (jaxlee.com not owned)
- **Baseurl:** `/jaxlee` (do not blank without a domain attached)
- **Identity:** `jaxlee-digital` GitHub account (separate from
  Sheehan's primary identity)

Full background: `infra/jaxlee-site/README.md`.

## Common jobs

### Publish a blog post

1. Read `skills/jekyll-publish-post/SKILL.md`.
2. Draft into `_drafts/<slug>.md`.
3. Preview locally (see below).
4. Show Sheehan; wait for explicit approval.
5. Promote draft → `_posts/YYYY-MM-DD-<slug>.md`.
6. Commit + push via `skills/git-safe-commit/` and
   `skills/jekyll-deploy/`.

### Deploy a layout, asset, or config change

1. Read `skills/jekyll-deploy/SKILL.md`.
2. Make the change.
3. Preview locally.
4. Show Sheehan the diff; wait for approval.
5. Commit + push.
6. Verify live.

### Add a new resume, log entry, project, etc.

This site has collections beyond `_posts/`: `_resumes`, `_log`,
and a `_drafts/`. Same approval flow — draft, review, promote,
push.

## Local preview

Ruby + Bundler required (or use Podman per
`infra/oceanspray-site/README.md` style; jaxlee README still
documents native Ruby).

```bash
cd ~/.openclaw/workspace/jaxlee-site
bundle install               # first time
bundle exec jekyll serve     # http://localhost:4000/jaxlee
bundle exec jekyll serve --drafts   # to preview _drafts/
```

If you'd rather use Podman (no host Ruby), adapt the
`oceanspray-site` README's container recipe — same image,
just point at `jaxlee-site` and use `--baseurl /jaxlee`.

## Repo-specific rules

- **`baseurl` is `/jaxlee`.** Keep it that way until a custom
  domain is attached. Blanking it breaks every internal link.
- **Internal links** must use `{{ site.baseurl }}/path/` —
  never hardcoded `/jaxlee/path/`.
- **GitHub Pages plugins only.** Allowed: `jekyll-feed`,
  `jekyll-seo-tag`, `jekyll-sitemap`, `jekyll-paginate`.
  Anything else won't build.
- **No `.github/workflows/`.** Pages does the build directly.
  Don't add Actions unless we're consciously moving off the
  default-branch build.

## Approval gate

Per `USER.md` and `SOUL.md`:

- Drafts only until approved.
- Only finished, polished work goes up.
- Nothing publishes without Sheehan's explicit OK.

Acceptable approval phrases: "publish it", "ship it",
"promote to post", "looks good, push". Anything ambiguous → ask.

**Send screenshots at all three viewports before asking for
approval** — desktop, tablet, mobile. Mobile catches things
desktop hides (nav collapse, hero cropping, CTA reachability,
text reflow).

Viewports:

| Label | Size | Approximates |
|---|---|---|
| `desktop` | 1280×900 | Laptop |
| `tablet` | 820×1180 | iPad portrait |
| `mobile` | 390×844 | iPhone 14/15 |

Reusable helper (note `/jaxlee` baseurl):

```bash
shoot() {
  # shoot <url-path-after-baseurl> <slug>
  local path="$1" slug="$2"
  mkdir -p /tmp/jaxlee-preview-shots
  chmod 777 /tmp/jaxlee-preview-shots
  for vp in "desktop:1280,900" "tablet:820,1180" "mobile:390,844"; do
    local label="${vp%%:*}" size="${vp##*:}"
    podman run --rm --network host --user 0:0 \
      -v /tmp/jaxlee-preview-shots:/out:Z \
      docker.io/zenika/alpine-chrome --no-sandbox \
      --hide-scrollbars --window-size="$size" \
      --screenshot="/out/${slug}-${label}.png" \
      "http://localhost:4000/jaxlee${path}"
    cp "/tmp/jaxlee-preview-shots/${slug}-${label}.png" \
      "/home/sheehan/.openclaw/workspace/jaxlee-${slug}-${label}.png"
  done
}

# Examples:
shoot "/" home
shoot "/blog/2026/05/your-post-slug/" post
```

Attach via `MEDIA:` lines, labeled. Check mobile for nav, no
horizontal scroll, CTAs above the fold. Clean up images after push:
`rm -f /home/sheehan/.openclaw/workspace/jaxlee-*-{desktop,tablet,mobile}.png`

Trivial copy edits (typo, one-word body change) may skip tablet
/ mobile when no layout change is possible. Default is all three.

## Git ops — location matters

**Use `git -C <absolute-path>` for every git command.** `cd` does
not persist between exec calls in the OpenClaw gateway — each
command re-enters from `workdir`, so `cd jaxlee-site && git …`
actually runs git from the workspace root. The workspace repo is
a separate git repo that tracks this whole tree as content, so a
wrong-path `git add -A` will silently stage workspace files.

Right pattern:

```bash
SITE=/home/sheehan/.openclaw/workspace/jaxlee-site
git -C "$SITE" status
git -C "$SITE" add <files>
git -C "$SITE" commit -m "..."
git -C "$SITE" push origin main
```

Sanity check before any add/commit:

```bash
git -C "$SITE" rev-parse --show-toplevel
# must print: /home/sheehan/.openclaw/workspace/jaxlee-site
```

If it prints the workspace path instead, you're targeting the
wrong repo — stop and re-check the `-C` path.

## Identity / git auth

This repo is under the `jaxlee-digital` GitHub account, which
is **not** Sheehan's primary identity. Per-repo credential
helper must be set:

```bash
git -C ~/.openclaw/workspace/jaxlee-site config --get-all credential.helper
```

If unset and push fails with `could not read Username`, see
`infra/oceanspray-site/README.md` § Git auth for the pattern
(same helper applies).

## Where things live

- `_posts/` — published posts
- `_drafts/` — drafts (not built unless `--drafts`)
- `_layouts/` — page templates
- `_includes/` — partial templates
- `_sass/` — styles
- `_scripts/` — site automations
- `assets/` — images, CSS output, JS
- `_resumes/`, `_log/`, `photography/`, `software/`,
  `sailing.md`, `work.md`, `writing/` — collection content
- `_config.yml` — site config

## Verify deploy

```bash
curl -sI https://jaxlee-digital.github.io/jaxlee/ | head -5
curl -s https://jaxlee-digital.github.io/jaxlee/sitemap.xml | grep -m1 lastmod
```

## Related

- `infra/jaxlee-site/README.md` — full infra notes
- `skills/jekyll-publish-post/SKILL.md`
- `skills/jekyll-deploy/SKILL.md`
- `skills/git-safe-commit/SKILL.md`
