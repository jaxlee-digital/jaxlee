---
title: "Show, don't tell: closing the agent feedback loop"
date: 2026-05-22
last_updated: 2026-05-22
author: sheehan
co_authors: [nova]
tags: [agents, jekyll, podman, infra, meta]
excerpt: "My AI assistant ships code I can't see her working on. So I taught her to send screenshots, and then I taught a second model to look at the screenshots first."
---

I was at the kitchen table this morning when Nova fixed a color
contrast bug on oceansprayfl.com. She lowered `--c-muted` from
`#7f8a92` to `#5e6970`, watched Lighthouse jump from 0.96 to 1.00,
and asked if she could push.

I was nowhere near a laptop. But I knew exactly what the site
looked like. She'd sent three screenshots: desktop, tablet, mobile.
The dates on the blog cards were a hair darker. The "we'll beat
any quote" strip had crisper white text. Push approved. Done in
the time it took to drink coffee.

This post is about how that worked, and why I think it matters
more than the change itself.

## The problem with text-only agents

Most coding agents talk in diffs. They tell you what they changed
and you nod along, trusting that the words match the pixels. For
backend work this is fine. For anything visual it's a lie by
omission.

A diff says `color: #5e6970`. It does not say "the dates on the
home page got slightly darker but the layout is unchanged and the
hero still looks right and mobile didn't break." Those facts only
exist on a rendered page. If the agent can't show you the page,
you have to render it yourself before you trust the change.

That breaks the loop. Now I'm the bottleneck. The agent did the
work in ten seconds; I'm spending three minutes spinning up a
preview to verify it.

## Closing the loop

The fix is conceptually obvious: have the agent render the page
and send me an image. The execution is where it gets interesting,
because there's no host Ruby on my machine and I review from
phones, boats, and waiting rooms more than from desks.

The pipeline I landed on:

1. Edit the Jekyll source.
2. A Podman container running `ruby:3.2` rebuilds the site.
3. A second container running headless Chrome takes screenshots
   at three viewports.
4. The screenshots get attached to a Telegram message and
   delivered to my phone.
5. I tap approve or push back.
6. Agent commits and pushes.

Total elapsed: under a minute for a small change. No host
dependencies. Works from anywhere I get a Telegram notification.

## The container preview

No Ruby on the host. Every site uses the same recipe:

```bash
podman run -d --name oceanspray-preview \
  --userns=keep-id \
  -v /home/sheehan/.openclaw/workspace/oceanspray-site:/site:Z \
  -w /site \
  -p 127.0.0.1:4000:4000 \
  -e HOME=/tmp \
  docker.io/library/ruby:3.2 \
  sh -c "bundle install --quiet && bundle exec jekyll serve --host 0.0.0.0"
```

First run takes about a minute while bundler installs into
`vendor/bundle` (which lives in the repo, gitignored). Subsequent
starts are five seconds. Port binds to `127.0.0.1` only; nothing
about the preview should reach the LAN.

When I want to throw it away, `podman rm -f oceanspray-preview`
and start over. No bundler cache rot, no Ruby version skew, no
`dnf update` ever breaking my preview.

I run two of these at once on different ports when I'm reviewing
both my sites. Each one is fully isolated; one site's gem set
can't pollute the other.

## The screenshot helper

This is the actual feedback channel. A bash function in the
agent's session that knows how to shoot any URL at three
viewports and put the result somewhere Telegram can pick it up:

```bash
shoot() {
  local path="$1" slug="$2"
  for vp in "desktop:1280,900" "tablet:820,1180" "mobile:390,844"; do
    local label="${vp%%:*}" size="${vp##*:}"
    podman run --rm --network host --user 0:0 \
      -v /tmp/preview-shots:/out:Z \
      docker.io/zenika/alpine-chrome --no-sandbox \
      --hide-scrollbars --window-size="$size" \
      --screenshot="/out/${slug}-${label}.png" \
      "http://localhost:4000${path}"
    cp "/tmp/preview-shots/${slug}-${label}.png" \
       "/home/sheehan/.openclaw/workspace/${slug}-${label}.png"
  done
}

shoot "/" home
shoot "/services/seawall-stabilization/" seawall
```

Three viewports, one function call. Files land in the workspace
root where the agent can attach them with `MEDIA:` directives
that OpenClaw translates into Telegram attachments.

The viewports are deliberate. 1280×900 is the laptop common case.
820×1180 is iPad portrait. 390×844 is iPhone 14/15, where every
layout failure I've ever shipped lived. Mobile catches what
desktop hides: hamburger nav collapse, hero cropping, CTAs that
end up below the fold, text reflow that breaks vertical rhythm.

## Why three, not one

I argued with Nova about this. Her first version of the workflow
shot one image, 1280×900, and called it done. That works for
desktop-first sites built by desktop-first developers, which is
about half the web and nearly none of my actual visitors.

The mobile-only failures are the ones that ship and stay shipped,
because nobody on the team uses mobile during development. By
the time someone complains, the bad version has been live for
weeks.

Three images cost nothing. The cron container doesn't care; the
Telegram message gets slightly longer. The fix-it-fast-fail-fast
math is overwhelmingly in favor of always shooting all three.

## Teaching the agent to look

The pipeline I described above is the first version. It has one
remaining weakness: I'm the only reviewer. Nova ships images at
me and trusts that I'll catch what's broken. If I'm distracted,
or in a hurry, or just bored of looking at three screenshots a
day, the broken thing slips through. The agent is fast; my
attention is the bottleneck.

So I added a second reviewer. Before any screenshot reaches my
phone, Nova hands it to a local vision model first.

The model is `gemma3:27b`, running on a Framework Desktop in my
office over Tailscale. It's not big enough for nuanced design
critique. It is exactly big enough to answer "does this page
look obviously broken," which is the question I'm answering
ninety percent of the time when I review a screenshot.

The prompt is structured. Three images in, one verdict per
viewport out, plus an overall `ship` or `fix-before-sending`.
Nova reads the verdict before she attaches anything:

- If the model says `ship`, the screenshots go to my phone.
- If the model says `fix-before-sending`, Nova reads the flagged
  issues, decides if they're real, and either fixes them and
  re-shoots, or sends with a one-line note explaining why she
  considered the flag and dismissed it.

This morning the model caught the mobile hero on oceansprayfl.com
pushing both CTAs below the fold. I would have approved that
screenshot, because it looked basically fine and I'm not a
desktop-vs-mobile pixel measurer. The model wasn't fooled. Nova
tightened the mobile hero by about 140 pixels, re-shot, the
model said `ship`, and I got a clean image with the CTAs in the
right place.

The model is wrong sometimes. It hallucinates details if you let
it talk too long. It does not know your brand. It cannot judge
whether a color is the *correct* shade of warm gray. But for the
binary question "is something obviously broken," it is faster
and more attentive than I am, and it is free.

What I get out of this: I review fewer screenshots, but the ones
I see are higher confidence. Nova ships more changes per day,
but they hit my phone already pre-checked. The loop is tighter
on both sides.

## What this enables

The mechanical pipeline is one thing. The bigger shift is that
**review can now happen anywhere I have my phone**. Which is
everywhere.

A few specific things that work now and didn't before:

- **Approving a contrast fix from the kitchen.** This morning's
  case. Took a sip of coffee, looked at three images, typed
  "push," done.
- **Reviewing a service-page edit from the boat.** Last weekend
  we were anchored off Marco Island. I had a Telegram thread
  open. Nova drafted a tweak to the seawall page, sent the
  three shots, I approved. The boat doesn't have a desk.
- **Catching mobile regressions before they ship.** Between the
  screenshot pipeline and the vision pre-check, Nova now catches
  layout bugs that used to ride the diff straight to production.
  This morning's hero-too-tall on oceansprayfl.com is a working
  example. The diff said "changed `--c-muted` to `#5e6970`."
  The screenshots said "and also your mobile CTAs are buried."
  Only the second one mattered.

## What this isn't

It's not autonomous. Every push is still gated on me looking at
the images and saying "yes." If the screenshots look wrong, I
push back; if they're missing entirely, I refuse to approve.
The agent does the work; I do the verification. That ratio is
the point.

It's also not a substitute for actually using the site. I still
load oceansprayfl.com on my own phone, in my own browser, after
deploys. Screenshots from headless Chrome aren't pixel-identical
to mobile Safari. But the screenshots catch 90% of what would
be a failure before deploy, and the on-device check catches the
rest.

## The principle

The takeaway, more abstract than the recipe: **agents that ship
visual changes need a visual feedback channel.** Diff-based
review is a regression from the GUI tools we already had. The
fix is to bring the GUI back as an artifact: render the page,
ship the image, let the human see.

Whatever you're building with an agent, ask yourself what the
agent thinks the result looks like, and what you'd need to see
to actually trust it. If those two answers don't match, you're
trusting on faith. Faith is not a deploy strategy.

For me, on a Jekyll site, the answer is three PNGs delivered
to my phone. For someone else it might be a Storybook snapshot,
or a deployed preview URL, or a Loom recording. The medium
doesn't matter. The principle does.

Show, don't tell.

---

*Drafted with Claude (anthropic/claude-opus-4-7), pre-checked
with gemma3:27b on a local Ollama instance, reviewed and shipped
by Sheehan. The full workflow lives in
[oceansprayfl.com's WORKFLOW.md](https://github.com/jaxlee-digital/oceansprayfl/blob/main/WORKFLOW.md)
and the underlying skill in the workspace. Possibly going public
as a separate repo later. TBD.*
