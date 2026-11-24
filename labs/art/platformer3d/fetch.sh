#!/usr/bin/env bash
# Downloads the Kenney Starter Kit 3D Platformer models (CC0) used by the 3D
# playgrounds and lessons. Each file is pinned to a commit and checked against
# its git blob hash. The models load their colours from Textures/colormap.png.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_url=https://raw.githubusercontent.com/KenneyNL/Starter-Kit-3D-Platformer/3fa8a04b1c01ab23db43123d4ce814a34c3fc7f0/models

while read -r name blob; do
  [[ -n "$name" ]] || continue
  target="$here/$name"
  mkdir -p -- "$(dirname -- "$target")"
  if [[ -f "$target" && "$(git hash-object "$target")" == "$blob" ]]; then
    continue
  fi
  curl --fail --silent --show-error --location --retry 3 "$source_url/$name" -o "$target.part"
  if [[ "$(git hash-object "$target.part")" != "$blob" ]]; then
    echo "Checksum mismatch for $name" >&2
    rm -f -- "$target.part"
    exit 1
  fi
  mv -- "$target.part" "$target"
done <<'MODELS'
Textures/colormap.png b16f5b40aee81ff33b40abda49cc223c52a17996
character.glb 49ea3291f2a4fcd4ad4c667c49ecb5e09576d944
platform-large.glb 28c4e090e6c244b3e28c3544120869e0afb9e9f1
brick.glb ab5426b00eb289ab827f3a16042c3ec3e5864250
block-coin.glb 051cfc98f85f2e3ae985324ed3035f7a345e5814
flag.glb 013a525f3789b1d0722f787fce8dc77fd663923b
MODELS
