#!/bin/bash

owner="frenzywall"
repo="HelloWorld.deb"
branch="main" 

api_url="https://api.github.com/repos/$owner/$repo/contents?ref=$branch"
raw_url_base="https://raw.githubusercontent.com/$owner/$repo/$branch"

files_json=$(curl -s $api_url)

file_list=$(echo "$files_json" | jq -r '.[] | select(.type == "file") | .path')

if [ -z "$file_list" ]; then
    gum style --bold --foreground 1 "🚨 No files found in the repository."
    exit 1
fi

selected_file=$(echo "$file_list" | gum choose)

if [ -z "$selected_file" ]; then
    gum style --bold --foreground 1 "❌ No file selected."
    exit 1
fi

raw_url="$raw_url_base/$selected_file"

gum style --bold --border="double" --foreground 2 --background 0 --padding 1 \
    "📂 Selected file: $selected_file"
gum style --bold --border="double" --foreground 3 --background 0 --padding 1 \
    "🔗 Raw URL: $raw_url"

gum input --placeholder "Press Enter to copy the raw URL: $raw_url"

