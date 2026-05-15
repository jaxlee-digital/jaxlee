# WORKFLOW: jaxlee-site

Operating manual for Sheehan's personal site at
`jaxlee-digital.github.io/jaxlee`. Read this first before
publishing or deploying anything to this repo.

## TL;DR

- **Repo:** `jaxlee-digital/jaxlee` (GitHub)
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
