# Local Command Finder
grp is a lightweight offline command searcher and clipboard tool that helps you store, browse, and copy useful shell commands quickly — all from your terminal.
It uses fzf for fuzzy searching and jq for handling a JSON-based command database.

# ✨ Features

🔍 Fuzzy search your local collection of commands

📋 Copy commands directly to your clipboard

➕ Add new commands interactively

📃 List all stored commands in a readable table

🧱 Works entirely offline — no internet required

🐧 Supports Linux, macOS, and WSL

# SETUP
# Move script to PATH
mkdir -p ~/.local/bin
mv grp.sh ~/.local/bin/
chmod +x ~/.local/bin/grp.sh

# Create command database
echo "[]" > ~/commands.json

# Install deps
sudo apt install jq fzf xclip -y

| Command          | Description            |
| ---------------- | ---------------------- |
| `./grp.sh`        | Search & copy commands |
| `./grp.sh --add`  | Add a new command      |
| `grp.sh --list` | View all commands      |

# Example
./grp.sh --add
 Title: Show IP
 Command: ip addr show
 Tags: network

./grp.sh
 → Search, press Enter to copy
