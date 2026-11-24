#!/usr/bin/env bash
set -euo pipefail

project=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
output="$project/../site/runner"
release=https://github.com/Razoric480/custom-godot-builder/releases/download/learn-4.6.3
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT

curl --fail --silent --show-error --location --retry 3 \
  "$release/godot-learn.4.6.3.editor.zip" -o "$scratch/editor.zip"
curl --fail --silent --show-error --location --retry 3 \
  "$release/godot-learn.4.6.3.templates.zip" -o "$scratch/templates.zip"
(
  cd "$scratch"
  sha256sum --check <<'CHECKSUMS'
b091884044209d84207cb060ed514e49f8aed17d1c889f528af2e88ece0ee257  editor.zip
25e61dae0e806229939ca419feb31a12c26336252c528af5b8d832471fd6f860  templates.zip
CHECKSUMS
  unzip -qj editor.zip godot.linuxbsd.editor.x86_64
  chmod +x godot.linuxbsd.editor.x86_64
  unzip -qj templates.zip godot.web.template_debug.wasm32.nothreads.zip
)

web_template="$scratch/godot.web.template_debug.wasm32.nothreads.zip"
unzip -p "$web_template" godot.js > "$output/engine.js"
unzip -p "$web_template" godot.wasm > "$output/engine.wasm"
XDG_CACHE_HOME="$scratch/cache" XDG_CONFIG_HOME="$scratch/config" XDG_DATA_HOME="$scratch/data" \
  "$scratch/godot.linuxbsd.editor.x86_64" --headless --path "$project" \
  --export-pack Web "$output/engine.pck"

labs="$project/../labs"
play="$project/../site/play"
template_cache="$project/../.cache/godot"
play_template="$template_cache/web-4.6.3.zip"
if [[ ! -f "$play_template" ]]; then
  mkdir -p "$template_cache"
  curl --fail --silent --show-error --location --retry 3 \
    "https://github.com/godotengine/godot-builds/releases/download/4.6.3-stable/Godot_v4.6.3-stable_export_templates.tpz" \
    -o "$scratch/official.tpz"
  unzip -p "$scratch/official.tpz" templates/web_nothreads_release.zip > "$play_template"
fi
printf '%s  %s\n' '1446f79dc12f60ce5d244c39fb6628ec298337ca5c4f91a16491feea72aa1bc9' "$play_template" | sha256sum --check
unzip -qjo "$play_template" godot.js godot.wasm godot.audio.worklet.js godot.audio.position.worklet.js -d "$play"
# Use the standard editor for the playgrounds' glTF importer.
editor_name=Godot_v4.6.3-stable_linux.x86_64
curl --fail --silent --show-error --location --retry 3 \
  "https://github.com/godotengine/godot-builds/releases/download/4.6.3-stable/$editor_name.zip" \
  -o "$scratch/$editor_name.zip"
printf '%s  %s\n' 'd0bc2113065e481c9c2c2b2c37daa4e8be3fe9e27f0ab9ab0b6096e9a37907f3' "$scratch/$editor_name.zip" | sha256sum --check
unzip -qjo "$scratch/$editor_name.zip" "$editor_name" -d "$scratch"

labs_godot() {
  XDG_CACHE_HOME="$scratch/cache" XDG_CONFIG_HOME="$scratch/config" XDG_DATA_HOME="$scratch/data" \
    "$scratch/$editor_name" --headless --path "$labs" "$@"
}

# Download the CC0 art that is not stored in the repository: Kenney's Racing
# Kit, Pixel Adventure 1 and Kenney's Starter Kit 3D Platformer.
for fetch in "$labs"/art/*/fetch.sh; do
  bash "$fetch"
done
labs_godot --import

# Smoke-test the lessons before packaging them.
smoke() {
  local script=$1 passed=$2
  labs_godot --script "$script" 2>&1 | tee "$scratch/smoke.log"
  if grep -qE 'SCRIPT ERROR|Parse Error|SMOKE FAIL|TOUR FAIL' "$scratch/smoke.log" \
    || ! grep -q "$passed" "$scratch/smoke.log"; then
    echo "The smoke test $script failed." >&2
    exit 1
  fi
}
smoke res://ci/smoke_racing.gd 'SMOKE PASSED'
smoke res://ci/tour.gd 'TOUR PASSED'

labs_godot --export-pack Web "$play/playgrounds.pck"
mkdir -p "$play/source"
cp "$labs/"*.gd "$play/source/"
mkdir -p "$project/../site/animation/assets"
find "$labs/art" -maxdepth 1 -type f ! -name '*.import' -exec cp {} "$project/../site/animation/assets/" \;
(
  cd "$labs"
  zip -qr "$play/playgrounds-godot.zip" project.godot playground.tscn ./*.gd art -x "*.import"
)
