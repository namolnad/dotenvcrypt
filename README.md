# dotenvcrypt 🛡️🔐

**Securely encrypt, manage, and load your `.env` files in public repositories.**

> Inspired by `rails credentials`, `dotenvcrypt` ensures your API keys and other `.env` secrets are encrypted while keeping your workflow simple.

---

## 🚀 Features

- ✅ Encrypt `.env` files into `.env.enc` for safe storage in Git.
- ✅ Decrypt and load environment variables securely into the shell.
- ✅ Edit encrypted `.env.enc`, then re-encrypt after saving.

---

## 📦 Installation

### Using Homebrew (recommended)

```bash
brew install namolnad/formulae/dotenvcrypt
```

## 🔧 Usage

### Basic Commands

```bash
# Encrypt a .env file
dotenvcrypt encrypt .env .env.enc

# Decrypt an encrypted file
dotenvcrypt decrypt .env.enc

# Edit an encrypted file (decrypts, opens editor, re-encrypts)
dotenvcrypt edit .env.enc

# Load encrypted environment variables into your shell
eval "$(dotenvcrypt decrypt .env.enc)"
```

### Key Management

dotenvcrypt looks for your encryption key in these locations (in order):

1. Command line argument: `--key YOUR_SECRET_KEY`
1. Environment variable: `DOTENVCRYPT_KEY`
1. File: `./.dotenvcrypt.key` (in the current directory)
1. File: `$XDG_CONFIG_HOME/dotenvcrypt/secret.key` (or `$HOME/.config/dotenvcrypt/secret.key`)
1. File: `$HOME/.dotenvcrypt.key`
1. Interactive prompt (if no key is found)

### Real-World Example

Add this to your shell profile (`.zshrc`, `.bashrc`, etc.) to automatically load variables:

```bash
# Set up encryption key (example using 1Password CLI)
dotenvcrypt_key_path="$XDG_CONFIG_HOME/dotenvcrypt/secret.key"
if [[ ! -f $dotenvcrypt_key_path || ! -s $dotenvcrypt_key_path ]]; then
  mkdir -p $(dirname $dotenvcrypt_key_path)
  # Replace with your preferred key storage method
  (op item get your-item-reference --fields password) > $dotenvcrypt_key_path
  chmod 600 $dotenvcrypt_key_path
fi

# Load encrypted environment variables if envcrypt is installed
if command -v dotenvcrypt &> /dev/null; then
  set -a  # automatically export all variables
  eval "$(dotenvcrypt decrypt $HOME/.env.enc)"
  set +a  # stop automatically exporting
fi
```
