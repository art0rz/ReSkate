#!/bin/sh
# Updates ReSkate.dll and ReSkateLauncher.exe in a game folder from this fork's "latest" build.
# For the Steam Deck's Desktop Mode: run `sh update-from-fork.sh [GAME_FOLDER]`.
# The folder (the one with Skate.exe) is remembered after the first run.
set -eu

REPO="@REPO@"
FILES="ReSkateLauncher.exe ReSkate.dll"
conf="${XDG_CONFIG_HOME:-$HOME/.config}/reskate-update.conf"
here=$(cd "$(dirname "$0")" && pwd)

dir="${1:-}"
[ -n "$dir" ] || { [ ! -f "$conf" ] || dir=$(cat "$conf"); }
[ -n "$dir" ] || { [ ! -f "$here/Skate.exe" ] || dir="$here"; }
if [ -z "$dir" ]; then
    echo "Usage: sh $0 GAME_FOLDER   (the folder that has Skate.exe)" >&2
    exit 1
fi
if [ ! -f "$dir/Skate.exe" ]; then
    echo "No Skate.exe in $dir" >&2
    exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
for file in $FILES; do
    echo "Downloading $file"
    curl -fL --progress-bar -o "$tmp/$file" "https://github.com/$REPO/releases/download/latest/$file"
done
for file in $FILES; do
    [ ! -f "$dir/$file" ] || cp -f "$dir/$file" "$dir/$file.bak"
    mv -f "$tmp/$file" "$dir/$file"
done

mkdir -p "$(dirname "$conf")"
printf '%s\n' "$dir" > "$conf"
echo "Updated $dir (the old files are kept as .bak)"
