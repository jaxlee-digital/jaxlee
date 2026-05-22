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
- **Live:** https://jaxlee-digital.github.io/jaxlee
- **Engine:** Jekyll via `github-pages` gem, default-branch build
- **Theme:** custom (in-repo)
- **Custom domain:** none (jaxlee.com not owned)
- **Baseurl:** `/jaxlee` (do not blank without a custom domain)
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

Ruby + Bundler on host:

```bash
SITE=/home/sheehan/.openclaw/workspace/jaxlee-site
( cd "$SITE" && bundle install )                          # first time
( cd "$SITE" && bundle exec jekyll serve )                # http://localhost:4000/jaxlee
( cd "$SITE" && bundle exec jekyll serve --drafts )       # include _drafts/
```

If you'd rather use Podman (no host Ruby), adapt the
`oceanspray-site/WORKFLOW.md` container recipe — same image,
just point at `jaxlee-site` and use `--baseurl /jaxlee`.

## Accessibility & standards

**WCAG 2.2 AA on everything user-facing.** Full checklist:
`jaxlee-site/AGENT.md` "Accessibility & standards" — that file is
the canonical reference for *both* sites. Audit tool:
`skills/a11y-audit/`.

Run the audit before any deploy that touches templates, layouts,
or new pages. Skip for routine posts that reuse existing
components.

## Repo-specific rules

- **`baseurl` is `/jaxlee`.** Keep it. Blanking breaks every link
  until a custom domain is attached.
- **Internal links** must use `{{ site.baseurl }}/path/`. Never
  hardcode `/jaxlee/path/`.
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
- `_drafts/` — drafts (not built unless `--drafts`)
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
