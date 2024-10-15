#!/bin/bash

echo "Installing jq..."
sudo apt-get install jq --yes

install_gum() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update && sudo apt install -y gum
}

if ! command -v gum &> /dev/null; then
    echo "🚨 gum is not installed. Installing gum..."
    install_gum
fi

verify_package() {
    echo "Verifying the package..."
    gpg --verify hello-world.deb.sig hello-world.deb
    if [ $? -eq 0 ]; then
        echo "✅ The package is verified successfully!"
    else
        echo "❌ Verification failed! The package may have been tampered with."
        exit 1
    fi
}

install_package() {
    echo "Installing the Hello World package..."
    sudo dpkg -i hello-world.deb
    if [ $? -ne 0 ]; then
        echo "⚠️ There were issues during installation. Fixing dependencies..."
        sudo apt-get install -f
    fi
    echo "🎉 The Hello World package has been installed successfully!"
}

# Start of the script
gum style --bold --foreground 4 "🎉 Welcome to the Hello World Package Installer! 🎉"

# Ask for the input type
key_source=$(gum choose "Download GPG key from URL" "Use local GPG key file")

if [ "$key_source" == "Download GPG key from URL" ]; then
    while true; do
        key_url=$(gum input --placeholder "Please enter the URL of the public key to download")
        
        # Check if a URL was provided
        if [[ -z "$key_url" ]]; then
            gum style --bold --foreground 1 "❌ No URL provided! Please enter a valid URL."
        else
            gum style --bold "Downloading the public key from $key_url..."
            if wget --show-progress "$key_url" -O public_key.gpg; then
                gum style --bold --foreground 2 "✅ Public key downloaded successfully!"
                break
            else
                gum style --bold --foreground 1 "❌ Failed to download the public key. Please check the URL and try again."
            fi
        fi
    done
else
    # Display the current working directory when the user selects the local file option
    current_dir=$(pwd)
    gum style --bold --foreground 3 "Current working directory: $current_dir"
    
    while true; do
        key_file=$(gum input --placeholder "Please enter the local path of the public key file")
        
        # Check if file path is provided and exists
        if [[ -z "$key_file" ]]; then
            gum style --bold --foreground 1 "❌ No file path provided! Please enter a valid file path."
        elif [[ ! -f "$key_file" ]]; then
            gum style --bold --foreground 1 "❌ File does not exist! Please enter a valid file path."
        else
            gum style --bold "Copying the local GPG key file from $key_file..."
            rsync --progress "$key_file" public_key.gpg
            break
        fi
    done
fi

# Import the public key
gum style --bold "Importing the public key..."
if ! gpg --import public_key.gpg; then
    gum style --bold --foreground 1 "❌ Failed to import the public key. Exiting..."
    exit 1
fi

# Verify the package and install
verify_package
install_package

# Highlight the successful installation using a box
gum style --border="double" --foreground 2 --background 0 --padding 1 \
    "🎉 Hello World Package Installed Successfully! 🎉"

gum style --bold "Running the Hello World program..."
hello-world

# Emphasize the thank you message in a box
gum style --border="double" --foreground 4 --background 0 --padding 1 \
    "Thank you for using the Hello World Package Installer!"

read -p "$(gum style --bold 'Press Enter to exit...')"

