#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.local/share/applications/

mkdir -p ~/.susurrus0
cd ~/.susurrus0
wget -O file.zip # link to release
unzip -o file.zip
rm file.zip

echo "Exiting in 3 seconds..."
sleep 3
