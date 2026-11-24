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
