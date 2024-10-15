#!/bin/bash

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "gum is not installed. Please install it to use this script."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it to use this script."
    exit 1
fi

# Function to fetch repositories for a specified GitHub user
fetch_repositories() {
    local owner="$1"
    api_url="https://api.github.com/users/$owner/repos"
    repos_json=$(curl -s "$api_url")

    # Check if the response contains an error
    if [[ $(echo "$repos_json" | grep -c '"message":') -gt 0 ]]; then
        gum style --bold --foreground 130 "🚨 Error fetching repositories for $owner. Please check the username."
        exit 1
    fi

    # List repository names
    echo "$repos_json" | jq -r '.[].full_name'
}

# Function to fetch files from a specified GitHub repository
fetch_files() {
    local repo="$1"
    local branch="$2"

    api_url="https://api.github.com/repos/$repo/contents?ref=$branch"
    files_json=$(curl -s "$api_url")

    # Check if the response contains an error
    if [[ $(echo "$files_json" | grep -c '"message":') -gt 0 ]]; then
        gum style --bold --foreground 130 "🚨 Error fetching files from $repo. Please check the repository name."
        exit 1
    fi

    file_list=$(echo "$files_json" | jq -r '.[] | select(.type == "file") | .path')
    echo "$file_list"
}

# Main script execution loop
while true; do
    # Section header with styling
    gum style --bold --foreground 82 --padding="1" --margin="1 0" \
        "🌍 GitHub File Explorer"

    # Get user input for GitHub owner
    owner=$(gum input --placeholder "Enter GitHub owner (or type 'exit' to quit)" --prompt="🔍 " --prompt.foreground="94")
    if [[ "$owner" == "exit" ]]; then
        gum style --bold --foreground 82 "👋 Exiting the script. Goodbye!"
        exit 0
    fi

    # Fetch and display repositories for the specified user
    repos=$(fetch_repositories "$owner")
    if [ -z "$repos" ]; then
        gum style --bold --foreground 130 "🚨 No repositories found for user: $owner."
        continue
    fi

    # Use gum to display the repositories in a selection menu
    selected_repo=$(echo "$repos" | gum choose --header="Select a Repository" --header.foreground="82" --item.foreground="94")
    if [ -z "$selected_repo" ]; then
        gum style --bold --foreground 130 "❌ No repository selected."
        continue
    fi

    # Get the branch name (default to main)
    branch=$(gum input --placeholder "Enter branch name (default: main)" --prompt="🌿 " --prompt.foreground="94")
    branch=${branch:-main}

    # Fetch and display files from the selected repository
    files=$(fetch_files "$selected_repo" "$branch")
    if [ -z "$files" ]; then
        gum style --bold --foreground 130 "🚨 No files found in the repository."
        continue
    fi

    # Use gum to display the files in a selection menu
    selected_file=$(echo "$files" | gum choose --header="Select a File" --header.foreground="82" --item.foreground="94")

    if [ -z "$selected_file" ]; then
        gum style --bold --foreground 130 "❌ No file selected."
        continue
    fi

    # Construct the raw URL
    raw_url_base="https://raw.githubusercontent.com/$selected_repo/$branch"
    raw_url="$raw_url_base/$selected_file"

    # Display selected file information with styling
    gum style --bold --foreground 82 --background 236 --padding="1" --margin="1 0" \
        "📂 Selected file: $selected_file"
    gum style --bold --foreground 94 --background 236 --padding="1" --margin="1 0" \
        "🔗 Raw URL: $raw_url"

    # Optionally, allow copying the raw URL
    gum input --placeholder "Press Enter to copy the raw URL: $raw_url"

    echo ""  # Print a blank line for better readability
done

