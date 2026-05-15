#!/usr/bin/env bash
# Generate a new "5 random Flickr photos" post for jaxlee.com.
#
# Pulls from the public Flickr photostream RSS feed (no API key needed).
# Picks 5 random photos from the most recent ~20 uploads, writes a new
# post in _posts/ with a GLightbox-powered lightbox gallery.
#
# Usage:
#   _scripts/flickr-random-post.sh
#   _scripts/flickr-random-post.sh "Custom Post Title"
#
# Requires: curl, python3.

set -euo pipefail

FLICKR_USER_ID="127544400@N03"
FLICKR_PROFILE="https://www.flickr.com/photos/${FLICKR_USER_ID}/"
COUNT=5

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SITE_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
POSTS_DIR="$SITE_DIR/_posts"

DATE_ISO="$(date +%Y-%m-%d)"
DATE_FULL="$(date +%Y-%m-%d\ %H:%M:%S\ %z)"
SLUG="flickr-random-${DATE_ISO}"
OUT_FILE="$POSTS_DIR/${DATE_ISO}-${SLUG}.md"

if [[ -f "$OUT_FILE" ]]; then
  SLUG="${SLUG}-$(date +%H%M)"
  OUT_FILE="$POSTS_DIR/${DATE_ISO}-${SLUG}.md"
fi

FEED_URL="https://www.flickr.com/services/feeds/photos_public.gne?id=${FLICKR_USER_ID}&format=json&nojsoncallback=1"
FEED_JSON="$(curl -fsSL "$FEED_URL")"

python3 - "$OUT_FILE" "$DATE_FULL" "$FLICKR_PROFILE" "$COUNT" <<PY
import json, random, sys, os
from datetime import datetime

out_file, date_full, profile, count = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
data = json.loads('''$FEED_JSON''')
items = data.get('items', [])
if len(items) < count:
    print(f"Only {len(items)} items in feed; using all.", file=sys.stderr)
picks = random.sample(items, min(count, len(items)))

def img_urls(item):
    m = item['media']['m']
    return m, m.replace('_m.jpg', '_b.jpg')

tiles = []
sources = []
for i, p in enumerate(picks, 1):
    thumb, big = img_urls(p)
    link = p['link']
    tiles.append(f'''  <a href="{big}"
     class="glightbox" data-gallery="flickr-random" data-description="View on Flickr">
    <img src="{thumb}" alt="Flickr photo" loading="lazy">
  </a>''')
    sources.append(f'<a href="{link}">{i}</a>')

body = f'''---

date: {date_full}
last_updated: {date_full.split()[0]}
tags: [photography, flickr]
excerpt: "Five photos pulled at random from my Flickr feed. Click any to expand."
---

Five photos pulled at random from my [Flickr feed]({profile}). Click any to expand.

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/glightbox/dist/css/glightbox.min.css">

<div class="flickr-grid">
{chr(10).join(tiles)}
</div>

<p style="margin-top: 1.5rem; font-size: 0.9em; opacity: 0.7;">
  Sources: {" · ".join(sources)}
</p>

<style>
.flickr-grid {{
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 0.75rem;
  margin: 1.5rem 0;
}}
.flickr-grid a {{ display: block; overflow: hidden; border-radius: 4px; }}
.flickr-grid img {{
  width: 100%;
  height: 100%;
  aspect-ratio: 1 / 1;
  object-fit: cover;
  display: block;
  transition: transform 0.3s ease;
}}
.flickr-grid a:hover img {{ transform: scale(1.05); }}
</style>

<script src="https://cdn.jsdelivr.net/npm/glightbox/dist/js/glightbox.min.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function () {{
    GLightbox({{ selector: '.glightbox' }});
  }});
</script>
'''

with open(out_file, 'w') as f:
    f.write(body)
print(f"Wrote {out_file}")
PY
