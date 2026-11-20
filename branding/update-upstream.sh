#!/usr/bin/env bash
# Pull the latest upstream Linphone sources into android/ and ios/, then re-apply the Oasis branding.
# Usage: branding/update-upstream.sh [android_ref] [ios_ref]     (defaults: master master)
set -euo pipefail
cd "$(dirname "$0")/.."

ANDROID_REF="${1:-master}"
IOS_REF="${2:-master}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

import() { # <dir> <repo> <ref>
  local dir="$1" repo="$2" ref="$3"
  git clone -q --depth 1 --branch "$ref" "https://github.com/BelledonneCommunications/$repo" "$TMP/$repo"
  local sha; sha="$(git -C "$TMP/$repo" rev-parse HEAD)"
  git rm -rq --ignore-unmatch "$dir" >/dev/null || true
  rm -rf "$dir" && mkdir -p "$dir"
  (cd "$TMP/$repo" && git archive HEAD) | tar -x -C "$dir"
  echo "$repo $ref $sha"
}

{
  import android linphone-android "$ANDROID_REF"
  import ios     linphone-iphone  "$IOS_REF"
} | tee branding/UPSTREAM.txt

python3 branding/rebrand.py
echo
echo "Done. Review with 'git status' / 'git diff', then commit."
