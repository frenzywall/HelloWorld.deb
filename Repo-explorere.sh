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

# Function to list repositories
function list_repositories() {
    local owner="$1"
    repos_json=$(curl -s "https://api.github.com/users/$owner/repos?per_page=100")
    repo_list=$(echo "$repos_json" | jq -r '.[].name')

    if [ -z "$repo_list" ]; then
        error_message "No repositories found for user: $owner."
        exit 1
    fi

    # Create formatted repository names as hyperlinks
    repo_links=$(echo "$repo_list" | awk -v owner="$owner" '{print "\033[1;34m" $0 "\033[0m - [https://github.com/" owner "/" $0 "]"}')

    # Display repository names
    gum style --bold --foreground 3 --background 0 --padding 1 "📦 Repositories for user: $owner"

    # Display the repository links and allow selection
    selected_repo=$(echo "$repo_links" | gum choose --header "Select a repository (press '↑' or '↓' to navigate):")

    # Check if "Go Back" is selected
    if [[ "$selected_repo" == *"Go Back"* ]]; then
        return 1
    fi

    # Extract the selected repository name
    selected_repo_name=$(echo "$selected_repo" | awk -F ' - ' '{print $1}' | sed 's/ \x1B\[[0-9;]*m//g')

    echo "$selected_repo_name"
}

# Main script starts here
welcome_message

while true; do
    # Prompt for GitHub repository owner
    owner=$(gum input --placeholder "🧑‍💻 Enter the GitHub repository owner (e.g., frenzywall):")
    if [ -z "$owner" ]; then
        error_message "Owner cannot be empty."
        exit 1
    fi

    # List repositories and capture the selected repository
    selected_repo=$(list_repositories "$owner")

    # Break the loop if the user chooses to go back
    if [ -z "$selected_repo" ]; then
        continue
    fi

    # Prompt for branch name with a default value
    branch=$(gum input --placeholder "🌿 Enter the branch name (default: main):" --value "main")

    # Construct the API URL and raw URL base for the selected repository
    api_url="https://api.github.com/repos/$owner/$selected_repo/contents?ref=$branch"
    raw_url_base="https://raw.githubusercontent.com/$owner/$selected_repo/$branch"

    # Fetch the file list from the GitHub API
    files_json=$(curl -s "$api_url")

    # Check if the file list is empty or null
    file_list=$(echo "$files_json" | jq -r '.[] | select(.type == "file") | .path')

    if [ -z "$file_list" ]; then
        error_message "No files found in the repository: $selected_repo."
        continue
    fi

    # Let the user select a file from the list
    selected_file=$(echo "$file_list" | gum choose --header "📄 Select a file:")

    if [ -z "$selected_file" ]; then
        error_message "No file selected."
        continue
    fi

    # Construct the raw URL for the selected file
    raw_url="$raw_url_base/$selected_file"

    # Display the selected file and its raw URL
    success_message "📂 Selected file: $selected_file"
    success_message "🔗 Raw URL: $raw_url"

    # Prompt to copy the raw URL
    gum input --placeholder "Press Enter to copy the raw URL: $raw_url"
done
