#!/bin/bash

install_gum() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update && sudo apt install -y gum
}

if ! command -v gum &> /dev/null; then
    gum style --bold --foreground 1 "🚨 gum is not installed. Installing gum..."
    install_gum
fi

verify_package() {
    gum style --bold "Verifying the package..."
    gpg --verify hello-world.deb.sig hello-world.deb
    if [ $? -eq 0 ]; then
        gum style --bold --foreground 2 "✅ The package is verified successfully!"
    else
        gum style --bold --foreground 1 "❌ Verification failed! The package may have been tampered with."
        exit 1
    fi
}

install_package() {
    gum style --bold "Installing the Hello World package..."
    sudo dpkg -i hello-world.deb
    if [ $? -ne 0 ]; then
        gum style --bold --foreground 1 "⚠️ There were issues during installation. Fixing dependencies..."
        sudo apt-get install -f
    fi
    gum style --bold --foreground 2 "🎉 The Hello World package has been installed successfully!"
}

gum style --bold --foreground 4 "🎉 Welcome to the Hello World Package Installer! 🎉"

# Ask for the input type
key_source=$(gum choose "Download GPG key from URL" "Use local GPG key file")

if [ "$key_source" == "Download GPG key from URL" ]; then
    key_url=$(gum input --placeholder "Please enter the URL of the public key to download")
    gum style --bold "Downloading the public key from $key_url..."
    wget -q "$key_url" -O public_key.gpg
else
    # Display the current working directory when the user selects the local file option
    current_dir=$(pwd)
    gum style --bold --foreground 3 "Current working directory: $current_dir"
    
    key_file=$(gum input --placeholder "Please enter the local path of the public key file")
    gum style --bold "Using the local GPG key file at $key_file..."
    cp "$key_file" public_key.gpg
fi

gum style --bold "Importing the public key..."
gpg --import public_key.gpg

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

