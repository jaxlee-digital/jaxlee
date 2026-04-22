# AGENT.md — Jaxlee site coding & content conventions

Design system, content rules, writing voice. Nova reads this before
making site changes; updates it when Sheehan sets a new rule.

**Scope:** applies only inside `jaxlee-site/`.

**Operations, hosting, auth, and deploy live in:**
[`infra/jaxlee-site/README.md`](../../infra/jaxlee-site/README.md)
(absolute: `~/.openclaw/workspace/infra/jaxlee-site/README.md`).

---

## Design system — do not drift

All colors/fonts come from CSS custom properties in `main.css`. Don't
add new hex colors inline; extend the palette variables if needed.

### Palette (pulled from the jaxlee digital logo)

| Token           | Value     | Use                                     |
|-----------------|-----------|-----------------------------------------|
| `--ink`         | `#25262c` | body text, headings                     |
| `--ink-soft`    | `#3e3e3e` | secondary text                          |
| `--ink-muted`   | `#737373` | meta/muted                              |
| `--ink-faint`   | `#a9a9a9` | timestamps, section labels              |
| `--rule`        | `#ece3d6` | hairlines, borders (toned to paper)     |
| `--paper`       | `#fcf2e8` | page background (warm cream)            |
| `--paper-alt`   | `#f5e8d8` | inline code background, raised cards    |
| `--accent`      | `#db997c` | rose-gold — brand accent                |
| `--accent-soft` | `#ddb49e` | lighter rose-gold — hovers, states      |
| `--cool`        | `#00b2ff` | sky blue — reserved for rare use        |

### Type

- **Display:** Poppins (300–700) — hero, section labels, nav, H-tags
- **Body:** Urbanist (300–700) — body copy
- Both loaded via Google Fonts in `main.css`

### Signature motifs

- **No signature period.** The coral-period-after-title motif from the
  old palette was retired 2026-04-22 when the brand shifted to rose-gold.
- **Brand mark:** circular logo (`assets/images/brand/jaxlee-digital-128.png`)
  in the header next to the wordmark. 40px square, `border-radius: 50%`.
- Section labels: tiny, uppercase, letter-spaced, with a 2px top rule.
- Muted image saturation (`filter: saturate(0.95)`), lifted on hover.
- Rose-gold hover state on links; never underline in default state.

---

## Content rules

### Collections → site sections

Each section is a Jekyll collection. Add a markdown file, it shows up.

| Collection     | URL              | Nav label    |
|----------------|------------------|--------------|
| `_photography` | `/photography/`  | Photography  |
| `_software`    | `/software/`     | Software     |
| `_craft`       | `/craft/`        | Craft        |
| `_resumes`     | `/resumes/`      | Résumés      |
| `_posts`       | `/writing/`      | Writing      |

**Woodworking + 3D printing merged into Craft** (2026-04-22). Both are
hand-made things; one section is cleaner than two near-empty ones.
**Blog renamed to Writing** to soften the daily-blog obligation.

### Front matter (collection items)

```yaml
---
title: "Short, title-case"
date: YYYY-MM-DD
excerpt: "One sentence. Used on archives and home preview."
cover: /assets/images/<section>/<file>.jpg   # optional
---
```

### Blog posts

- Filename: `_posts/YYYY-MM-DD-kebab-slug.md`
- Permalink pattern: `/blog/:year/:month/:slug/` (set in `_config.yml`)
- Casual, first-person voice. No corporate filler.
- Footer byline: `— Sheehan Commette` (em dash, space).

### Standalone pages

Top-level `.md` files with explicit `permalink:` in front matter.
Current: `about.md`, `sailing.md`, `work.md`.

Use:
- `<section class="about">` for the about page structure
- `<section class="prose">` for everything else long-form

### Images

- Put under `/assets/images/<topic>/`
- Full resolution source files are OK; we don't have a pipeline yet
  (if it gets bad we'll add `jekyll-picture-tag`)
- Always include meaningful `alt` text; empty `alt=""` is only valid
  for purely decorative gallery images
- Prefer 16:9 or 4:3 crops for covers; portraits get 1:1

---

## Layouts — when to use which

| Layout     | Use for                                      |
|------------|----------------------------------------------|
| `default`  | Base wrapper — header, nav, footer           |
| `home`     | `index.md` only                              |
| `archive`  | Collection index pages (auto-lists items)    |
| `item`     | Individual collection entries (cover + body) |
| `post`     | Blog posts                                   |

New page types should extend `default` and add a scoped CSS class,
not modify existing layouts unless the change applies globally.

---

## CSS rules

- **One file:** `assets/css/main.css`. Don't split unless/until it
  crosses ~1000 lines and we need `_sass/` modules.
- **Scope by block class**: `.hero__title`, `.archive__list`, etc.
  (BEM-ish — no deep nesting, no element selectors for content).
- **No utility frameworks.** No Tailwind. No Bootstrap.
- **No inline styles** except for dynamic content (e.g. bg images).
- **Responsive:** one `@media (max-width: 640px)` block at the
  bottom of the file. Add more breakpoints only when clearly needed.
- **Clamp()** for fluid sizing: `clamp(min, fluid, max)`.

---

## Nav

Edit `_data/nav.yml`. Current order:

```
Home → Photography → Software → Craft → Writing → Résumés → About
```

Rule: creative sections first (visual → technical → physical),
then temporal (writing), then professional (résumés), then identity (about).

**Résumés** is a parent page listing individual CVs. Current children:
`/resumes/consulting/`, `/resumes/sailing/`. Add new résumés by creating
`/resumes/<name>/` pages and linking them from `resumes/index.md`.

---

## Positioning

**jaxlee digital is a field notebook.**

- A record, not a feed — no schedule, no posting obligation
- Open scope: photography, software, craft, writing, anything that
  catches Sheehan's attention
- Personal brand, not a studio. Not for hire (see sheehan.club for that).
- Pseudonymous. Jaxlee = the creative identity, distinct from real-name
  professional presence on sheehan.club.

**Note (2026-04-22):** the earlier "finished things only" framing was
retired. Field notes can be anything — rough, in-progress, reflective.
Use judgment on whether something's ready to post, but the rule isn't
"only finished work."

## Writing voice

Pulled from sheehan.club content and Sheehan's tone:

- First-person, conversational, unpolished in a good way
- Specifics over abstractions (tapioca starch, not "a starch")
- Routine, outdoors, family, software as recurring themes
- "Finding the extraordinary in the ordinary"
- Don't overwrite or sanitize when porting existing posts
- Title things plainly; let the work speak

---

## What Nova should NOT do without asking

- Buy a custom domain or change DNS
- Delete or rename existing posts/pages
- Add third-party tracking, analytics, ads, comments
- Change the accent color or typeface
- Change the repo name, visibility, or description
- Rotate or commit the GitHub PAT
- Add build steps that break native Pages (e.g. custom plugins that
  require GitHub Actions) — if needed, flag it and propose

## What Nova can do freely

- Add new collection items, blog posts, pages
- Port more sheehan.club content if Sheehan asks
- Style tweaks inside the existing palette/type system
- Commit and push to `main`
- Download and optimize images
- Fix typos, bugs, broken links
- Update this file when Sheehan gives a new rule

---

## Changelog

A running log of notable decisions and changes. Prepend new entries.

### 2026-04-22
- **Positioning softened.** Tagline simplified to *A field notebook.*
  The earlier "finished things only" framing was too narrow; field
  notes can be anything. Manifesto updated; section intros that
  mentioned "finished pieces" were generalized.
- **Brand & positioning reset.** Site renamed Jaxlee → "jaxlee digital".
  Positioning: personal creative record, not for hire.
- **Logo added.** Circular rose-gold brand mark in header, favicons,
  Apple touch icons. Source at `assets/images/brand/`.
- **Palette retuned** to match the logo: rose-gold accent `#db997c`
  (was bright coral `#f0523d`), warm cream paper `#fcf2e8` (was
  `#fafafa`), hairlines toned to match.
- **Signature period removed** from hero and archive titles.
- **Content architecture simplified.**
  - Woodworking + 3D Printing collections merged into `_craft`
  - Blog renamed to Writing (URL: `/writing/`)
  - New `_resumes` section; `/sailing/` and `/work/` moved to
    `/resumes/sailing/` and `/resumes/consulting/` with a landing
    card list at `/resumes/`
- **Split project docs from code conventions.** Project-at-a-glance,
  directory layout, deploy/verify runbooks, and auth/secrets moved to
  `infra/jaxlee-site/README.md`. `AGENT.md` now focused purely on the
  design system, content rules, and writing voice.
- **Git auth cleanup.** Remote URL no longer embeds the PAT.
  Credential helper at `~/.openclaw/bin/git-credential-jaxlee` reads
  the token from `~/.openclaw/secrets/jaxlee-pat`.
- **Social links in footer.** Added Instagram (`jaxleedigital`),
  Instagram (`neka_pup`), and Adafruit Playground alongside Flickr.
  Driven by `social:` block in `_config.yml`.

### 2026-04-21
- Added `AGENT.md` (this file). Nova reads it before site edits,
  updates it when Sheehan sets a new rule.
- **Content port from sheehan.club.** Ported About bio, Work
  (consulting pitch), Sailing (full CV), two blog posts
  ("Hello World!", "DIY Dry Shampoo"), 8-photo adventures gallery.
  Skipped Squarespace template placeholders (news/*,
  technical-blog/*, videos/*).
- **Retheme.** Switched to sheehan.club palette (coral `#f0523d`,
  warm paper `#fafafa`), Poppins + Urbanist typography, editorial
  layout, coral period signature on hero/archive titles.
- **Initial scaffold & deploy.** Jekyll site scaffolded locally,
  pushed to `jaxlee-digital/jaxlee`, GitHub Pages enabled from
  `main` / root. Live at the canonical URL above.
