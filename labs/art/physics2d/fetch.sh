#!/usr/bin/env bash
# Downloads the 2D art used by the physics lessons: blocks, aliens, ground tiles
# and a background from Physics Assets by Kenney (CC0). Each file is pinned to a
# commit, checked against its git blob hash and given a short name.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_url=https://raw.githubusercontent.com/crystal-bit/angry-aliens/e676d009ba96cffb0eb7e6676985284d08a082cf/Assets/graphics/kenney_physicsAssets_v2/PNG

while read -r name blob path; do
  [[ -n "$name" ]] || continue
  target="$here/$name"
  if [[ -f "$target" && "$(git hash-object "$target")" == "$blob" ]]; then
    continue
  fi
  curl --fail --silent --show-error --location --retry 3 "$source_url/$path" -o "$target.part"
  if [[ "$(git hash-object "$target.part")" != "$blob" ]]; then
    echo "Checksum mismatch for $name" >&2
    rm -f -- "$target.part"
    exit 1
  fi
  mv -- "$target.part" "$target"
done <<'FILES'
background.png 8469d4aef0afba15fb640294fdc01728ae32e175 Backgrounds/colored_grass.png
grass.png 5f9178456e3c4a92c2316b4b6a1418cb7b4729b5 Other/grass.png
dirt.png c0426e82fb969828deefedadff43d56e3553b418 Other/dirt.png
wood-square.png b640aac2b0d619339ec0bdf14a2ba05f6e57bf66 Wood%20elements/elementWood022.png
wood-plank.png c67e25a0c4fd1b2f729299202e7409a4641cdc35 Wood%20elements/elementWood012.png
wood-post.png eba15922fba8fd4a8740ab3c0d0f70bb02cc7fb8 Wood%20elements/elementWood019.png
stone-square.png b58355af3d709a2d2eb94959f8e3b071ed6f83ee Stone%20elements/elementStone023.png
stone-plank.png 684bd615a70b1c18e1490ed8a96e14f4254a728c Stone%20elements/elementStone013.png
stone-post.png 85c625b3f3e60a7bfea97ac3f133b2e8b0acc2c9 Stone%20elements/elementStone020.png
alien-green.png e9f6db0e28c5b2c719daac153a9a73be43566780 Aliens/alienGreen_round.png
alien-pink.png 36060d07bd67ff9d43f3ee48a43fe0e085042607 Aliens/alienPink_square.png
FILES
