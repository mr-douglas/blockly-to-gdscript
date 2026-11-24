#!/usr/bin/env bash
# Downloads the Pixel Adventure 1 images (Pixel Frog, CC0) used by the 2D
# platformer lessons. Each file is pinned to a commit, checked against its git
# blob hash, and saved under a short name.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_url=https://raw.githubusercontent.com/SlayHorizon/godot-2d-platformer-demo/6944ec4c323dcbad470ff7654fec665f010f50d1/assets/pixel-adventure

while read -r name blob path; do
  [[ -n "$name" ]] || continue
  target="$here/$name"
  if [[ -f "$target" && "$(git hash-object "$target")" == "$blob" ]]; then
    continue
  fi
  url="$source_url/${path// /%20}"
  url="${url//(/%28}"
  url="${url//)/%29}"
  curl --fail --silent --show-error --location --retry 3 "$url" -o "$target.part"
  if [[ "$(git hash-object "$target.part")" != "$blob" ]]; then
    echo "Checksum mismatch for $name" >&2
    rm -f -- "$target.part"
    exit 1
  fi
  mv -- "$target.part" "$target"
done <<'IMAGES'
frog-jump.png 20b6dfee5b20d1d439c0a90ac8b4b1b33d977679 Main Characters/Ninja Frog/Jump (32x32).png
frog-fall.png 3b9715fe1cf3a215a898368f7faade3f4d49317b Main Characters/Ninja Frog/Fall (32x32).png
terrain.png 6674ca167f3c45111c4ceec66b071022751e8637 Terrain/Terrain (16x16).png
background-blue.png 3a854225a8bfc2bc98ef5744e72846dec94601e2 Background/Blue.png
apple.png 7736b4637241b9612aad7779624fb1a850f0d04e Items/Fruits/Apple.png
checkpoint-empty.png 82cb0a3be0e75ca4bf32dfd78007142097e084a5 Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png
checkpoint-raise.png fb558360fb087854e28fe706f52730e5953c1e3d Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png
checkpoint-wave.png 2d9be559d7915ce650eb10bfb2e7992287e902ee Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png
trophy.png 6e67748223af76ed84f5d4ed38fea2ffb1e42f4a Items/Checkpoints/End/End (Idle).png
spikes.png 133f58681f1992ffa3f33a261ad49d11077527f8 Traps/Spikes/Idle.png
saw.png 9f3a811dd59d0049adf2223f43579ebaab926825 Traps/Saw/On (38x38).png
platform.png a66da57acf963073c11dea35e19fb216166c1f13 Traps/Platforms/Brown On (32x8).png
button-play.png 04f3791e5c72729ef0e27b1c3d7123c9be4b3ffd Menu/Buttons/Play.png
button-restart.png b12b24d53603e49308ddebfc43c7c78c2d72aade Menu/Buttons/Restart.png
IMAGES
