#!/bin/bash
set -e 

install_jq() {
    echo "Installing jq..."
    sudo apt-get install jq --yes
}

install_gum() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update && sudo apt install -y gum
}

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

if ! command -v gum &> /dev/null; then
    echo "🚨 gum is not installed. Installing gum..."
    install_gum
fi

install_jq  # Install jq
gum style --bold --foreground 4 "🎉 Welcome to the Hello World Package Installer! 🎉"

key_source=$(gum choose "Download GPG key from URL" "Use local GPG key file")
if [ "$key_source" == "Download GPG key from URL" ]; then
    key_url=$(gum input --placeholder "Please enter the URL of the public key to download")
    if [[ -z "$key_url" ]]; then
        gum style --bold --foreground 1 "❌ No URL provided! Exiting..."
        exit 1
    fi
    
    gum style --bold "Downloading the public key from $key_url..."
    if ! wget --progress=bar "$key_url" -O public_key.gpg 2>wget_error.log; then
        gum style --bold --foreground 1 "❌ Failed to download the public key. Error log:"
        cat wget_error.log
        read -p "Press Enter to exit..."
        exit 1
    fi
    gum style --bold --foreground 2 "✅ Public key downloaded successfully."
else
    current_dir=$(pwd)
    gum style --bold --foreground 3 "Current working directory: $current_dir"
    while true; do
        key_file=$(gum input --placeholder "Please enter the local path of the public key file")
        if [[ -z "$key_file" ]]; then
            gum style --bold --foreground 1 "❌ No file path provided! Please enter a valid file path."
        elif [[ ! -f "$key_file" ]]; then
            gum style --bold --foreground 1 "❌ File does not exist! Please enter a valid file path."
        else
            gum style --bold "Using the local GPG key file at $key_file..."
            cp "$key_file" public_key.gpg
            break
        fi
    done
fi

gum style --bold "Importing the public key..."
if ! gpg --import public_key.gpg 2>gpg_error.log; then
    gum style --bold --foreground 1 "❌ Failed to import the public key. Error log:"
    cat gpg_error.log
    read -p "Press Enter to exit..."
    exit 1
fi
gum style --bold --foreground 2 "✅ Public key imported successfully."

verify_package
install_package

gum style --border="double" --foreground 2 --background 0 --padding 1 "🎉 Hello World Package Installed Successfully! 🎉"

if command -v hello-world &> /dev/null; then
    gum style --bold "Running the Hello World program..."
    hello-world
else
    gum style --bold --foreground 1 "❌ The Hello World program is not available."
fi

gum style --border="double" --foreground 4 --background 0 --padding 1 "Thank you for using the Hello World Package Installer!"
read -p "$(gum style --bold 'Press Enter to exit...')"
