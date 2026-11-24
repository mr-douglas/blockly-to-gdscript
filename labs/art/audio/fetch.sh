#!/usr/bin/env bash
# Downloads the CC0 sound effects and music used by the sound lessons.
#   jump, coin, land: Kenney, Starter Kit 3D Platformer
#   music-title, music-level: Juhani Junkala, 5 Chiptunes (Action)
# Each file is pinned to a commit and checked against its git blob hash.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
kenney=https://raw.githubusercontent.com/KenneyNL/Starter-Kit-3D-Platformer/3fa8a04b1c01ab23db43123d4ce814a34c3fc7f0/sounds
junkala=https://raw.githubusercontent.com/Boyquotes/alpha-space/85a87f6c091a2a4ed5ba49b3b226f7ecc8280089/game/music/Juhani%20Junkala%20%5BRetro%20Game%20Music%20Pack%5D

while read -r name blob url; do
  [[ -n "$name" ]] || continue
  url=${url//'$kenney'/$kenney}
  url=${url//'$junkala'/$junkala}
  target="$here/$name"
  if [[ -f "$target" && "$(git hash-object "$target")" == "$blob" ]]; then
    continue
  fi
  curl --fail --silent --show-error --location --retry 3 "$url" -o "$target.part"
  if [[ "$(git hash-object "$target.part")" != "$blob" ]]; then
    echo "Checksum mismatch for $name" >&2
    rm -f -- "$target.part"
    exit 1
  fi
  mv -- "$target.part" "$target"
done <<'FILES'
jump.ogg e52f6a07e25c127716f67f72d7a9132afad5603c $kenney/jump.ogg
coin.ogg 57cf9513c9b260feec360867166c220c6f701ce7 $kenney/coin.ogg
land.ogg 3d97f7b09210641f9f3bdf020ff728e8d868f5ba $kenney/land.ogg
music-title.ogg 9c112b3759899c3f4b0974a23bfbaedd563c3045 $junkala%20Title%20Screen.ogg
music-level.ogg f546b851b031083bd85b18264f14732faa61a175 $junkala%20Level%201.ogg
FILES
