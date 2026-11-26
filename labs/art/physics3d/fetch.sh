#!/usr/bin/env bash
# Downloads the 3D models used by the physics lessons from Platformer Kit by
# Kenney (CC0). Each file is pinned to a commit and checked against its git blob
# hash. The models load their colours from Textures/colormap.png.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_url=https://raw.githubusercontent.com/levinzonr/godot-asset-placer/7b4c4c1f54cfd8a9fef6d606c3026aa10fd6130b/demo/assets/kenney_platformer_kit

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
Textures/colormap.png c1499397a73ce1d09dbeecce1b32b244f197fc5b
crate.glb 534ee896b479cfe7bf47e45f343ea2254e9e5dae
crate-strong.glb 23b137f01e7a554843e99e6fb031586e9bf91a02
block-grass-large.glb ec65556b9a366f6a0ac4e3de826cac2e0b390255
tree.glb 7cfa14e1ae6f38a3c3a5f3d479ca300a4a0a885d
flowers.glb 60da3e9f6ac33e63385a0af1315b08abc6b3fe09
MODELS
