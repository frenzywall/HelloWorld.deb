#!/bin/bash

# Function to display a welcome message
function welcome_message() {
    gum style --bold --foreground 2 --background 0 --padding 1 \
        "🌟 Welcome to the GitHub File Explorer! 🌟"
}

# Function to display error messages
function error_message() {
    gum style --bold --foreground 1 "🚨 $1"
}

# Function to display a success message
function success_message() {
    gum style --bold --foreground 2 "$1"
}

# Function to fetch repositories
function fetch_repositories() {
    local owner="$1"
    api_url="https://api.github.com/users/$owner/repos"
    repos_json=$(curl -s "$api_url")
    if [[ $(echo "$repos_json" | grep -c '"message":') -gt 0 ]]; then
        gum style --foreground 212 "⚠️ Error fetching repositories for $owner. Please check the username."
        exit 1
    fi
    echo "$repos_json" | jq -r '.[].full_name'
}

# Function to fetch files in a repository
function fetch_files() {
    local repo="$1"
    local branch="$2"
    api_url="https://api.github.com/repos/$repo/contents?ref=$branch"
    files_json=$(curl -s "$api_url")
    if [[ $(echo "$files_json" | grep -c '"message":') -gt 0 ]]; then
        gum style --foreground 212 "⚠️ Error fetching files from $repo. Please check the repository name."
        exit 1
    fi
    echo "$files_json" | jq -r '.[] | select(.type == "file") | .path'
}

# Function to list repositories
function list_repositories() {
    local owner="$1"
    gum spin --spinner dot --title "Fetching repositories..." -- sleep 2
    repos=$(fetch_repositories "$owner")
    if [ -z "$repos" ]; then
        gum style --foreground 212 "📭 Oops! No repositories found for user: $owner."
        gum confirm "Try again?" && return 1 || return 0
    fi

    selected_repo=$(echo "$repos" | gum choose --header "📦 Select a repository (press '↑' or '↓' to navigate):")
    if [ -z "$selected_repo" ]; then
        gum style --foreground 212 "❌ No repository selected. Let's try again!"
        gum confirm "Continue?" && return 1 || return 0
    fi

    echo "$selected_repo"
}

# Function to list files in a repository
function list_files() {
    local repo="$1"
    local branch="$2"
    gum spin --spinner dot --title "Fetching files..." -- sleep 2
    files=$(fetch_files "$repo" "$branch")
    if [ -z "$files" ]; then
        gum style --foreground 212 "📂 This repo is empty! Let's look at another one."
        gum confirm "Continue?" && return 1 || return 0
    fi

    selected_file=$(echo "$files" | gum filter --placeholder "📄 Select a File" --indicator ">" --indicator.foreground 103)
    if [ -z "$selected_file" ]; then
        gum style --foreground 212 "❌ No file selected. Let's start over!"
        gum confirm "Continue?" && return 1 || return 0
    fi

    echo "$selected_file"
}

# Main script starts here
welcome_message

while true; do
    owner=$(gum input --placeholder "🧑‍💻 Enter the GitHub repository owner (e.g., frenzywall):")
    if [ -z "$owner" ]; then
        error_message "Owner cannot be empty."
        continue
    fi

    selected_repo=$(list_repositories "$owner")
    if [ -z "$selected_repo" ]; then
        continue
    fi

    branch=$(gum input --placeholder "🌿 Enter branch name (default: main)" --prompt "🌿 " --prompt.foreground 66 --value "main" --width 50)

    selected_file=$(list_files "$selected_repo" "$branch")
    if [ -z "$selected_file" ]; then
        continue
    fi

    raw_url_base="https://raw.githubusercontent.com/$selected_repo/$branch"
    raw_url="$raw_url_base/$selected_file"

    success_message "📂 Selected file: $selected_file"
    success_message "🔗 Raw URL: $raw_url"

    gum confirm "📋 Copy raw URL to clipboard?" && echo -n "$raw_url" | pbcopy && 
        success_message "✨ URL copied to clipboard! ✨"

    if ! gum confirm "🚀 Explore another repository?"; then
        break
    fi
done

gum style --bold --foreground 2 --background 0 --padding 1 \
    "👋 Thanks for using GitHub File Explorer! Goodbye!"
