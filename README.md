# iOS-Bypass-Tool

A powerful and automated script-based tool designed for **Linux environments (Kali Linux recommended)** to streamline the **jailbreak** and **Activation Lock Screen Bypass** process for **checkm8-vulnerable iOS devices**.

The tool is built with a **modular architecture** to ensure high performance, easy maintenance, and a clear user experience.

**Coded by: Me


## 🌟 Key Features

- **Fully Automated:** Orchestrates the jailbreak and bypass processes sequentially with a single command.
- **Clean Environment:** Specifically tailored for **Kali Linux** to minimize compatibility issues and dependency hell.
- **Smart & Flexible:**
  - Auto-detects system architecture (`x86_64` or `arm64`) to download the correct `palera1n` binary.
  - Automatically downloads required dependencies like `palera1n` and the `SSHRD_Script`.
- **Modular Architecture:** The project is split into `main.sh`, `jailbreak.sh`, and `bypass.sh` for clarity, easy debugging, and future development.
- **Clear User Interface:** Uses colored output to guide the user and provide status updates for each step.
- **Robust Logging:** Creates a dedicated log file for each session in the `logs/` directory, making troubleshooting simple.
- **Safe & Robust:**
  - Checks for `root` privileges before running.
  - Halts execution immediately if a critical step fails.
  - Includes an automatic cleanup `trap` to remove partial downloads if the script is interrupted or fails.

---

## ⚠️ Disclaimer

- This tool is intended for **educational and research purposes only**.
- The developers are not responsible for any illicit or unauthorized use of this tool. Using it on a device you do not own may be illegal.
- The `fakefs` (semi-tethered) jailbreak means you will need to re-run the jailbreak process if the device reboots.
- **Always back up your data** before proceeding. While this tool is not designed to erase data, unforeseen issues can always occur.

---

## 🛠️ Prerequisites

- A **Kali Linux** OS (or another Debian-based distribution).
- An active internet connection for downloading dependencies.
- An iOS device vulnerable to the `checkm8` exploit.
- A high-quality USB-A to Lightning/USB-C cable.

---

## ⚙️ Installation

1.  **Open a Terminal**
    Launch a terminal window in your Linux environment.

2.  **Clone the Repository**
    ```bash
    git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
    ```
    > **Note:** Replace `YOUR_USERNAME` and `YOUR_REPO_NAME` with your actual GitHub username and repository name.

3.  **Navigate to the Project Directory**
    ```bash
    cd YOUR_REPO_NAME
    ```

4.  **Grant Execution Permissions**
    This is a crucial one-time step to make the scripts executable.
    ```bash
    chmod +x main.sh jailbreak.sh bypass.sh
    ```

5.  **Install Dependencies**
    The tool requires `curl`, `wget`, and `libimobiledevice-utils` to function correctly.
    ```bash
    sudo apt update
    sudo apt install -y curl wget libimobiledevice-utils
    ```

---

## 🚀 How to Use

All operations are initiated from the main script, `main.sh`, which must be run with `sudo` privileges.

### Execution Steps

1.  **Run the Tool:** Open a terminal in the project directory and execute one of the commands below.
2.  **Phase 1 (Jailbreak):**
    - The tool will download `palera1n` if it's not already present.
    - It will prompt you to `Press [Enter]`.
    - Carefully follow the on-screen instructions provided by `palera1n` to put your device into **DFU mode**.
3.  **Phase 2 (Bypass):**
    - After a successful jailbreak, the tool will prompt you to `Press [Enter]` again.
    - **Ensure your device is in DFU mode** for this step (re-enter it if necessary).
    - The tool will then boot the SSH Ramdisk and apply the bypass automatically.
4.  **Completion:**
    - The device will reboot automatically.
    - Congratulations! The Activation Lock screen should now be bypassed.

### Command-Line Options

#### Basic Usage (Default Mode)
This command uses the recommended `--fakefs` jailbreak mode.

```bash
sudo ./main.sh
```

#### Specifying an iOS Version (Optional)
If `palera1n` struggles to auto-detect the iOS version, you can specify it manually.

```bash
sudo ./main.sh -i 15.7.1
```
> Replace `15.7.1` with your device's actual iOS version.

#### Using `rootless` Mode (Advanced)
For advanced users who prefer the `rootless` jailbreak.

```bash
sudo ./main.sh -m --rootless
```

#### Simulation Mode (For Testing)
To perform a "dry run" that shows what the tool *would* do without executing any real commands, use the `--simulate` flag. This is great for testing and debugging.

```bash
sudo ./main.sh --simulate
```


---

## 📄 License

This project is distributed under the MIT License. See `LICENSE` for more information.
