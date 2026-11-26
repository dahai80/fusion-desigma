#!/usr/bin/env bash
# fusion fork (dahai80/fusion-desigma#1): shell-layer branding for the Windows
# and Linux release artifacts. Renames every dist/desigma-* artifact to
# fusion-desigma-* and rewrites the matching .sha256 files so the recorded
# filenames stay valid. Runs in the release job after download-artifact, before
# Combine checksums. macOS artifacts are already branded by
# package-fusion-macos.sh. The binary and archive contents stay upstream —
# only the published filenames carry the fusion brand.
set -euo pipefail

dir="${1:-dist}"
if [ ! -d "$dir" ]; then
    echo "package-fusion-rename: $dir does not exist; nothing to rename" >&2
    exit 1
fi

renamed=0
for f in "$dir"/desigma-*; do
    [ -e "$f" ] || continue
    base=$(basename "$f")
    new="$dir/fusion-$base"
    mv "$f" "$new"
    echo "package-fusion-rename: $base -> fusion-$base"
    renamed=$((renamed + 1))

    # Keep the per-artifact checksum valid: same hash, new filename.
    sumfile="$dir/$base.sha256"
    if [ -f "$sumfile" ]; then
        hash=$(cut -d' ' -f1 "$sumfile")
        printf '%s  %s\n' "$hash" "fusion-$base" > "$dir/fusion-$base.sha256"
        rm "$sumfile"
    fi
done

if [ "$renamed" -eq 0 ]; then
    echo "package-fusion-rename: no desigma-* artifacts found (already branded?)"
fi
echo "package-fusion-rename: renamed $renamed artifact(s)"
