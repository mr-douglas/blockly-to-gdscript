#!/usr/bin/env bash
# Downloads the Kenney Racing Kit models (CC0) used by the racing lessons.
# Each file is pinned to a commit and checked against its git blob hash.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_url=https://raw.githubusercontent.com/kidscancode/3d_car_sphere/cabc5c0019e68913012fc41d7b2ded6dcef3be31/assets/kenney_racing_kit

while read -r name blob; do
  [[ -n "$name" ]] || continue
  target="$here/$name"
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
raceCarOrange.glb 62274f612f3c7749c20581677562da76167e2d9b
raceCarGreen.glb 30b97cba3a4d6f8d9259cb928e862e11c2bc3d23
treeLarge.glb 06743b646a0a48d02e834f1a107c622b35323e7e
treeSmall.glb 6190c726d75c546c47f7136fb5534bae989c6434
overheadLights.glb e8ce547d2a67e686222ef0261999bf9774e26836
bannerTowerRed.glb 3b14817c91e0069dea753ce4bdfc1ca7eca2a892
lightPostLarge.glb a2196af56b6a761ae54ae8510d2cd3a8db5d3f8c
tent.glb ad22a5278a8ce0bf76818695d9a907cd818dc766
flagCheckers.glb 6cb35bfd1c9d96cb69a2279a5fe8390e65631cd2
pylon.glb 233627a160b11c10bdc027efa8a18f6794b7c15f
MODELS
