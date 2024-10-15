#!/bin/bash
install_gum() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ " | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update && sudo apt install -y gum
}
if ! command -v gum &> /dev/null; then
    echo "🚨 gum is not installed. Installing gum..."
    install_gum
welcome_message() {
    gum style --bold --foreground 4 "🎉 Welcome to the Hello World Package Installer! 🎉"
    sleep 1
}
confirm_proceed() {

    gum style --bold "You are about to install the Hello World package. Do you want to continue? (y/n)"
    read -r confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Installation aborted by the user."
        exit 0
    fi
}
install_jq() {
    echo "Installing jq..."
    sudo apt-get install jq --yes
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
welcome_message
sleep 1
confirm_proceed
install_jq

fi
key_source=$(gum choose "Download GPG key from URL" "Use local GPG key file")
if [ "$key_source" == "Download GPG key from URL" ]; then
    while true; do
        key_url=$(gum input --placeholder "Enter the URL of the public key (must start with http:// or https://)")
        if ! [[ $key_url =~ ^https?:// ]]; then
            gum style --bold --foreground 1 "❌ Invalid URL format! Please start with http:// or https://."
            continue
        fi
        gum style --bold "Downloading the public key from $key_url..."
        sleep 1
        wget --progress=bar "$key_url" -O public_key.gpg
        if [ $? -ne 0 ]; then
            gum style --bold --foreground 1 "❌ Failed to download the public key. Please check the URL and try again."
            continue  
        fi
        break  
    done
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
sleep 2
gum style --bold "Importing the public key..."
gpg --import public_key.gpg
if [ $? -ne 0 ]; then
    gum style --bold --foreground 1 "❌ Failed to import the public key. Exiting..."
    exit 1
fi
verify_package
install_package
gum style --border="double" --foreground 2 --background 0 --padding 1 "🎉 Hello World Package Installed Successfully! 🎉"
gum style --bold "Running the Hello World program..."
sleep 1
hello-world
sleep 3
echo "Hello-World Package has been succesfully installed and verfied!"
echo "++++++++"
gum style --border="double" --foreground 4 --background 0 --padding 1 "Thank you for using the Hello World Package Installer! :)"
read -p "$(gum style --bold 'Press Enter to exit...')"

