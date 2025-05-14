#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.local/share/applications/

mkdir -p ~/.sustools
cd ~/.sustools
wget -O file.zip # link to release
unzip -o file.zip
rm file.zip

echo "Exiting in 3 seconds..."
sleep 3