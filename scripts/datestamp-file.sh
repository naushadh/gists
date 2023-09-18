#!/usr/bin/env bash

# Prefixes datestamp to the given file
# By default, it will target the latest screenshot stored in ~/Pictures/Screenshots
# For MacOS, please run the following first
#   defaults write com.apple.screencapture ~/Pictures/Screenshots
# For Windows Subsystem for Linux, please run the following first
#   ln -s /mnt/c/Users/$USERNAME/OneDrive\ -\ $ORG/Pictures ~/Pictures

default_dir="$HOME/Pictures/Screenshots/"

if [ -z "$1" ]; then
    source_file=$(find "$default_dir" -type f -exec ls -t1 {} + | head -1)
else
    source_file=$1
fi

if ! test -f "$source_file"; then
    echo "Invalid args!"
    echo "Usage: $(basename "$0") <path to file> [...<name suffix>]"
    exit 1
fi

today=$(date +%Y-%m-%d)
name_suffix=${2:-$(basename "$source_file")}
target_file=$(dirname "$source_file")/${today}_${name_suffix}

mv "$source_file" "$target_file"
echo "$target_file"
