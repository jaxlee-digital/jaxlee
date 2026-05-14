#!/usr/bin/env bash
# optimize-images.sh
#
# Resize + recompress photos for jaxlee-site.
# - Caps long edge at 2000px
# - JPEG quality 82, progressive, EXIF stripped
# - Generates .webp sibling at quality 80
# - Idempotent: skips files that look already optimized
#   (long edge <= 2000 AND filesize < 400KB) unless --force
#
# Requires: ImageMagick 7 (`magick`)
#
# Usage:
#   _scripts/optimize-images.sh                       # all assets/images/**
#   _scripts/optimize-images.sh path/to/dir           # one dir, recursive
#   _scripts/optimize-images.sh path/to/file.jpg      # one file
#   _scripts/optimize-images.sh --force [target]      # reprocess everything
#   _scripts/optimize-images.sh --no-webp [target]    # skip webp generation
#   _scripts/optimize-images.sh --dry-run [target]    # show what would happen

set -euo pipefail

MAX_EDGE=2000
JPEG_QUALITY=82
WEBP_QUALITY=80
SKIP_THRESHOLD_BYTES=$((400 * 1024))

force=0
dry_run=0
make_webp=1
target=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) force=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    --no-webp) make_webp=0; shift ;;
    -h|--help)
      sed -n '2,18p' "$0"; exit 0 ;;
    *) target="$1"; shift ;;
  esac
done

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
target="${target:-$repo_root/assets/images}"

if ! command -v magick >/dev/null 2>&1; then
  echo "error: ImageMagick (magick) not installed" >&2
  exit 1
fi

run() {
  if (( dry_run )); then
    echo "DRY: $*"
  else
    "$@"
  fi
}

needs_optimization() {
  local f="$1"
  (( force )) && return 0
  local size
  size="$(stat -c %s "$f")"
  local edge
  edge="$(magick identify -format '%[fx:max(w,h)]' "$f" 2>/dev/null || echo 0)"
  if [[ "$edge" -le "$MAX_EDGE" && "$size" -lt "$SKIP_THRESHOLD_BYTES" ]]; then
    return 1
  fi
  return 0
}

optimize_jpeg() {
  local f="$1"
  local tmp="${f}.tmp.jpg"
  run magick "$f" \
    -auto-orient \
    -resize "${MAX_EDGE}x${MAX_EDGE}>" \
    -strip \
    -interlace Plane \
    -sampling-factor 4:2:0 \
    -quality "$JPEG_QUALITY" \
    "$tmp"
  if (( ! dry_run )); then
    mv "$tmp" "$f"
  fi
}

generate_webp() {
  local f="$1"
  local out="${f%.*}.webp"
  run magick "$f" \
    -resize "${MAX_EDGE}x${MAX_EDGE}>" \
    -strip \
    -define webp:method=6 \
    -quality "$WEBP_QUALITY" \
    "$out"
}

process_file() {
  local f="$1"
  case "${f,,}" in
    *.jpg|*.jpeg)
      if needs_optimization "$f"; then
        local before
        before="$(stat -c %s "$f")"
        optimize_jpeg "$f"
        if (( ! dry_run )); then
          local after
          after="$(stat -c %s "$f")"
          printf '  jpeg %s: %dKB -> %dKB\n' "$f" $((before/1024)) $((after/1024))
        fi
      else
        echo "  skip (already small): $f"
      fi
      if (( make_webp )); then
        local webp_out="${f%.*}.webp"
        if [[ ! -f "$webp_out" || $force -eq 1 ]]; then
          generate_webp "$f"
          (( ! dry_run )) && printf '  webp %s\n' "$webp_out"
        fi
      fi
      ;;
    *.png)
      echo "  png passthrough (no resize): $f"
      ;;
    *)
      ;;
  esac
}

if [[ -f "$target" ]]; then
  echo "Optimizing single file: $target"
  process_file "$target"
elif [[ -d "$target" ]]; then
  echo "Optimizing directory: $target"
  while IFS= read -r -d '' f; do
    process_file "$f"
  done < <(find "$target" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0)
else
  echo "error: target not found: $target" >&2
  exit 1
fi

echo "Done."
