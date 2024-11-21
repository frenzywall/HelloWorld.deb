# Hello World Package

This package outputs "Hello World" to the terminal when executed. Below are the instructions for installation, verification, and usage.

Note!: If you face any dependencies errors at any point of time, run :
```bash
sudo apt-get install -f
```

# Hello World Package Installer

Welcome to the Hello World Package Installer! This script helps you install the Hello World package with verification!

## Dependencies.

Before running the installer, ensure you have the following installed:

- **curl**: For downloading files.
- **gpg**: For importing and verifying GPG keys.
- **gum**: For a better command-line user interface.

You can install them on Ubuntu/Debian-based systems with:

```bash
sudo apt update
```
## Installation

To install the Hello World package, follow these steps:

1. **Download the package:** 
   Ensure you have the .deb package file (`hello-world.deb`) and .deb.sig(`hello-world.deb.sig`) downloaded to your system.

   Clone this repo :
   ```bash
   git clone https://github.com/frenzywall/HelloWorld.deb.git
   ```

   cd to the downloaded git rep:
   ```bash
   cd HelloWorld.deb
   ```

3. **Install the package:** 
   Open a terminal and run the following command:
   ```bash
   sudo dpkg -i hello-world.deb
   ```

4. **Fix Dependencies (if needed):** 
   If there are any dependency issues, you can resolve them by running:
   ```bash
   sudo apt-get install -f
   ```

## Verification

To verify the authenticity of the package, you need to check the signature:

1. **Download the public key:** 

   ```bash
   wget https://github.com/frenzywall/HelloWorld.deb/blob/main/public_key.gpg
   ```
   

2. **Import the public key:** 
   Import the public key into your GPG keyring:
   ```bash
   gpg --import public_key.gpg
   ```

3. **Verify the package signature:** 
   Use the following command to verify the package signature:
   ```bash
   gpg --verify hello-world.deb.sig hello-world.deb
   ```
   If the output indicates `Good signature`, it means the package is authentic and has not been tampered with.

## Running the Package

To run the Hello World program, simply execute:

```bash
hello-world
```

You should see the output:
```
Hello World
```
## Easy way - Use the Install.sh script
1. In the cloned directory(HelloWorld.deb folder), open terminal and
   ```bash
   chmod +rwx install_hello_world.sh
   ```
   and
   
   ```bash
   ./install_hello_world.sh
   ```
   success!!

## Another-way (Pull the latest version of my Hello-world package from ghcr or dockerhub.io)

1. To pull:
```bash
docker pull ghcr.io/frenzywall/hello-world:latest
```
2. Do:
```bash
docker images
```
3. Find the image that has hello-world in its name and copy the image ID or Image name:
```bash
docker run -it a9ecd57a729a  #Runs the container in interactive mode(tty)
```
4. You should be in the docker terminal now, to test if the package is correctly installed:
```bash
which hello-world            #This should return something like this, /usr/local/bin/hello-world, as its installed outside of apt package manager , its installed in /usr/local/bin. 
```
5. Programs are installed here so that they are available system wide!

6. Finally! To test to run our program:
```bash
hello-world
```
Done! :)

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any problems, please file an issue along with a detailed description.

---

