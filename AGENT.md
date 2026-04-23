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

| Source         | URL              | Nav                                |
|----------------|------------------|------------------------------------|
| `_posts` all   | `/field-notes/`  | Field Notes → All                  |
| `_posts` tagged `photography` | `/photography/` | Field Notes → Photography |
| `_posts` tagged `software`    | `/software/`    | Field Notes → Software    |
| `_posts` tagged `craft`       | `/craft/`       | Field Notes → Craft       |
| `_log`         | `/log/`          | Log                                |
| `_resumes`     | `/resumes/`      | Résumés                            |

**Section landings are tag-filtered post views** (2026-04-23).
`_photography/` `_software/` `_craft/` collections were deleted;
their content lives in `_posts/` with appropriate tags. Landing pages
use the `tag-section` layout to filter and render cards. Nice URLs
preserved. **Writing renamed to Field Notes** and made the top-level
full-posts feed. Old `/writing/` redirects to `/field-notes/`.

**Top-nav hierarchy:** the four post landings live under a "Field
Notes" dropdown; Log, Résumés, and About stay top-level.

**Woodworking + 3D printing merged into Craft** (2026-04-22).

### Front matter (collection items + posts)

```yaml
---
title: "Short, title-case"
date: YYYY-MM-DD
author: sheehan              # handle from _data/authors.yml
co_authors: [nova]           # optional list of handles
tags: [topic, type]          # see tag taxonomy below
excerpt: "One sentence. Used on archives and home preview."
cover: /assets/images/<section>/<file>.jpg   # optional
---
```

### Blog posts

- Filename: `_posts/YYYY-MM-DD-kebab-slug.md`
- Permalink pattern: `/blog/:year/:month/:slug/` (set in `_config.yml`)
- Casual, first-person voice. No corporate filler.
- No footer byline on individual posts (handled by the byline
  include now).

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

| Layout        | Use for                                                    |
|---------------|------------------------------------------------------------|
| `default`     | Base wrapper. header, nav, footer                          |
| `home`        | `index.md` only                                            |
| `archive`     | Collection index pages (auto-lists items)                  |
| `item`        | Individual collection entries (cover + body)               |
| `post`        | Blog posts                                                 |
| `log-entry`   | `/log/` entries. one-off trips OR recurring places         |

House projects are **blog posts** with `tags: [house]`, not a separate
collection. Use the `post` layout and include a `<figure class="ba-pair">`
block in the body for before/after images. Landing page lives at
`/tag/house/`.

### Log entry modes

A `/log/` entry is either a **one-off trip** or a **recurring place**.

**One-off trip** (e.g. `2026-04-18-pine-island-sound.md`):
- Required: `title`, `date`, `cover`, `lat`, `lng`
- Optional: `location`, `facts`, `gallery`, `pins`
- No `recurring:` key (or `recurring: false`)

**Recurring place** (e.g. `big-hickory.md`):
- Required: `title`, `recurring: true`, `cover`, `lat`, `lng`, `visits: [...]`
- Required: `date` (of most recent visit, used for sort on /log/ index)
- `visits` is an array, newest or oldest order doesn't matter. layout
  sorts by visit `date` descending.
- Each visit: `date` (required), `note` (optional), `title` (optional),
  `gallery` (array of `{src, alt?, caption?}`)
- To add a visit: append one item to the `visits:` array, update
  top-level `date:` to the new visit's date, optionally swap `cover:`.
  That's it. No new file.

New page types should extend `default` and add a scoped CSS class,
not modify existing layouts unless the change applies globally.

---

## Accessibility & standards — hard requirement

Everything shipped must meet WCAG 2.2 AA at minimum. No exceptions
for "decorative" features, no "we'll fix it later." If a feature
can't be shipped accessibly, don't ship it.

### Defaults for every build

- **Semantic HTML first.** `<button>` for actions, `<a>` for
  navigation, proper heading hierarchy (one `<h1>` per page,
  no skipping levels), `<nav>` / `<main>` / `<aside>` / `<footer>`
  used per spec.
- **Keyboard operable.** Every interactive element is reachable
  and usable with Tab and arrow keys. No keyboard traps. Visible
  focus style always present (don't kill `outline` without a
  replacement).
- **ARIA used correctly or not at all.** `aria-label` /
  `aria-labelledby` for icon-only buttons. `aria-hidden="true"`
  on decorative imagery. `aria-live="polite"` for content that
  updates without navigation (carousels, bubbles, toasts).
  Never use ARIA to paper over broken semantics — fix the
  semantics.
- **Alt text.** Every `<img>` has an `alt` attribute. Decorative
  images use `alt=""` (empty, not missing) and `aria-hidden="true"`.
  Content images describe the content, not "image of."
- **Color contrast.** Body text ≥ 4.5:1 against background, large
  text / UI controls ≥ 3:1. Don't rely on color alone to convey
  state (add an icon, underline, or label).
- **Motion and animation.** Respect `prefers-reduced-motion` for
  anything that moves, scales, or transitions more than a trivial
  amount. Never auto-play media. Never auto-advance carousels.
- **Forms.** Every input has a visible `<label>` (not just a
  placeholder). Error messages are programmatically associated
  (`aria-describedby`). Errors announced, not just styled red.
- **Touch targets.** Minimum 44x44px for anything tappable.
- **Text zoom.** Layouts must hold up at 200% zoom without
  horizontal scrolling or broken layout.
- **Mobile.** Same accessibility rules apply. No keyboard-only
  features that break touch.

### Validation before "ship it"

- Tab through the changed page. Everything reachable? Focus visible?
- Read headings in order. Do they form a sensible outline?
- Check color contrast on any new text/UI against both `--paper`
  and `--paper-alt` backgrounds.
- If it moves, check `prefers-reduced-motion` reduces or kills it.

### When in doubt

- If a pattern is commonly inaccessible (drag-drop, canvas, custom
  dropdowns), flag it and propose an accessible version before
  building.
- MDN + WAI-ARIA Authoring Practices are the reference; not
  Stack Overflow snippets.

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

## Authorship

Authors live in `_data/authors.yml`. Handles, not full names, go in
front matter. Current handles:

- `sheehan` (human, primary)
- `nova` (AI, OpenClaw+Claude)

### Byline rules

- **Solo posts** set `author:` only. Byline: *"By Sheehan"*.
- **Co-authored posts** add `co_authors: [handle, ...]`. Byline:
  *"By Sheehan with Nova ✨"*.
- Nova's signature ✨ renders automatically from `authors.yml`.
- When Nova is in the byline (primary or co), an AI disclosure
  line appears under the byline linking to `/authors/nova/`.
- Default author if unset in a post: `sheehan` (via `_config.yml`
  defaults). Always be explicit anyway.

### When to credit Nova

- **Credit her** when she actually wrote substantial prose,
  scaffolded code, or did structural work for the post's subject.
- **Don't credit her** for tiny edits, typo fixes, or formatting.
- **Name the model** in the post body when AI tools are part of
  the story ("Claude via OpenClaw", "ChatGPT", etc.). See STRICT
  rules.

### Author pages

- `/authors/sheehan/` — bio + posts by Sheehan
- `/authors/nova/` — bio + "how Nova works on this site" + Nova's
  posts

## Tag taxonomy

Two orthogonal tag systems, applied together.

**Topic tags** (what it's about):
```
brand, design, jekyll, infra, photography, software, craft,
woodworking, 3d-printing, sailing, writing, meta, ai
```

**Post-type tags** (what kind of post it is):
```
note, project, retrospective, tutorial, field-log, gallery
```

Use **1–3 tags per post**. At least one topic tag and, if it fits,
one type tag. Tags live at `/tag/<slug>/`.

### Adding new tags

When using a new tag in a post, create the tag page:

```
tag/<slug>.md
---
layout: tag
permalink: /tag/<slug>/
tag: <slug>
title: "#<slug>"
---
```

Keep the list tight. If a tag only fits one post, reconsider it.

## Writing voice

Living reference, refined as Sheehan edits drafts. Update this
section whenever a correction lands — future drafts should match.

### Core posture

- First-person, conversational, unpolished in a good way
- Specifics over abstractions (tapioca starch, not "a starch")
- Title things plainly; let the work speak
- Don't overwrite or sanitize when porting existing posts

### Recurring themes

- Routine, outdoors, family, software
- "Finding the extraordinary in the ordinary"
- Deliberate design — Sheehan has been shaping this brand for a
  long time. Palette, logo, workspace, prints all chosen piece
  by piece. Never write it as coincidence or "happened by accident."

### STRICT rules (never violate without asking)

- **NEVER publish a post without explicit approval.** Drafts
  live in `_drafts/` with a slug-only filename
  (no date prefix). Sheehan's explicit "ship it" is required
  before moving to `_posts/YYYY-MM-DD-slug.md` and pushing.
  Preview with `bundle exec jekyll serve --drafts`. This rule
  applies to solo, co-authored, and Nova-primary posts equally.
- **Deliver drafts as pull requests.** Work on a `feat/...` or
  `draft/...` branch, push, open a PR against `main`. Sheehan
  reviews and merges. Do not merge to `main` or push directly
  to `main` for blog/log content without explicit "ship it" or
  "just publish." Structural/infra changes (layouts, config,
  CSS, fixes) may still go direct to main when appropriate.
- **NEVER use em-dashes (—) or en-dashes (–).** Use periods,
  commas, parentheses, or colons instead. Applies to posts,
  pages, excerpts, frontmatter, everything in the published site.
  This is a hard line. If a draft contains one, rewrite the
  sentence.
- **No self-important phrasing.** If a sentence sounds like a
  portfolio site selling itself, rewrite it. Show the work,
  don't announce the work. Plain is better.
  When in doubt, read it out loud: anything that sounds like
  marketing copy has to go.
- **No sycophancy, no filler, no "happy to help" energy.** This
  is Sheehan's voice, not a newsletter's. Dry when warranted.
- **Cite AI correctly and specifically.** Whenever AI helped with
  something mentioned in a post, name the tool, name the model
  if relevant, and describe what it did and what Sheehan directed.
  Examples:
  - "ChatGPT drew the logo. I gave it the palette, motifs, and
    feel I wanted."
  - "Claude (via OpenClaw) scaffolded the Jekyll site from my
    spec and wired up the CSS variables."
  - "Midjourney generated the cover image from my prompt."
  Wrong: vague phrasing like "designed by a friend," "generated,"
  or hiding the tool's involvement. Also wrong: crediting AI
  where Sheehan made the call (design direction, writing, final
  decisions are his).

  Tools currently in use on this project:
  - **ChatGPT** (OpenAI) — logo design, some copy ideation
  - **Claude via OpenClaw** — site scaffolding, porting,
    infra documentation, post drafts

### Things to avoid (learned from edits 2026-04-22)

- **No "the brand wrote itself" / serendipity framing.** The
  aesthetic is intentional, years-in-the-making work. Writing it
  as a lucky alignment flattens real effort.
- **Don't overclaim novelty.** If a topic is common ("I built a
  Jekyll site"), keep the post tight and specific to Sheehan's
  angle. Don't pad with generic walkthroughs.
- **Credit tools correctly.** Logo was generated by ChatGPT based
  on Sheehan's palette, motifs, and direction. Not a friend, not
  found. When mentioning AI-assisted work, name the tool plainly
  and keep ownership of the creative direction.
- **Short over long when in doubt.** 350 words beats 1200 unless
  there's something specific worth the length. Tutorial sections
  (directory trees, step-by-step build walkthroughs) belong in
  docs, not blog posts.

### Structure defaults

- Lead with the premise, not context-setting preamble
- One idea per section; H2 between sections
- Small honest moments > grand conclusions
- Close with what's next or what's hard, not a summary

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
