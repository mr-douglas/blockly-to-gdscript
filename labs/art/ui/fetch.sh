#!/usr/bin/env bash
# Downloads the CC0 font and heart icons used by the game interface lessons.
#   kenney-pixel.ttf: Kenney, Kenney Fonts
#   heart-full.png, heart-empty.png: Kenney, Pixel Platformer (tiles 44 and 46)
# Each file is pinned to a commit and checked against its git blob hash.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
fonts=https://raw.githubusercontent.com/SelinaDev/Godot-Roguelike-Tutorial/25cf7f708f93c1ad334f40ddbca0b6d431471d41/part_12/assets/fonts/kenney_kenney-fonts/Fonts
tiles=https://raw.githubusercontent.com/milosfarkas/coolest-project-2024/850dd1516ba77e53f53468d55265a1d6dfd28016/godot/assets/kenney_pixel-platformer/Tiles

while read -r name blob url; do
  [[ -n "$name" ]] || continue
  url=${url//'$fonts'/$fonts}
  url=${url//'$tiles'/$tiles}
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
kenney-pixel.ttf e6978d7d6f6a91ca8cdd5515e338110d9977fe69 $fonts/Kenney%20Pixel.ttf
heart-full.png d9c656341a2204a9b2819b81312c674218ceade9 $tiles/tile_0044.png
heart-empty.png 06672c914d8bb2fd0da94e03aa49bf4f17a6111a $tiles/tile_0046.png
FILES
