# Hello World Package

This package outputs "Hello World" to the terminal when executed. Below are the instructions for installation, verification, and usage.

## Installation

To install the Hello World package, follow these steps:

1. **Download the package:** 
   Ensure you have the .deb package file (`hello-world.deb`) and .deb.sig(`hello-world.deb.sig`) downloaded to your system.

2. **Install the package:** 
   Open a terminal and run the following command:
   ```bash
   sudo dpkg -i hello-world.deb
   ```

3. **Fix Dependencies (if needed):** 
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

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any problems, please file an issue along with a detailed description.

---

