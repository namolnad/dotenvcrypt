# envcrypt 🛡️🔐

**Securely encrypt, manage, and load your `.env` files in public repositories.**

> Inspired by `rails credentials`, `envcrypt` ensures your API keys and other `.env` secrets are encrypted while keeping your workflow simple.

---

## 🚀 Features

- ✅ Encrypt `.env` files into `.env.enc` for safe storage in Git.
- ✅ Decrypt and load environment variables securely into the shell.
- ✅ Edit encrypted `.env.enc`, then re-encrypt after saving.

---

## 📦 Installation

### Using Homebrew (recommended)

```bash
brew install namolnad/formulae/envcrypt
```

## 🔧 Usage

### Basic Commands

```bash
# Encrypt a .env file
envcrypt encrypt .env .env.enc

# Decrypt an encrypted file
envcrypt decrypt .env.enc

# Edit an encrypted file (decrypts, opens editor, re-encrypts)
envcrypt edit .env.enc

# Load encrypted environment variables into your shell
eval "$(envcrypt decrypt .env.enc)"
```

### Key Management

EnvCrypt looks for your encryption key in these locations (in order):

1. Command line argument: `--key YOUR_SECRET_KEY`
1. Environment variable: `ENVCRYPT_KEY`
1. File: `$XDG_CONFIG_HOME/envcrypt/secret.key` (or `$HOME/.config/envcrypt/secret.key`)
1. File: `$HOME/.envcrypt.key`
1. Interactive prompt (if no key is found)

### Real-World Example

Add this to your shell profile (`.zshrc`, `.bashrc`, etc.) to automatically load variables:

```bash
# Set up encryption key (example using 1Password CLI)
envcrypt_key_path="$XDG_CONFIG_HOME/envcrypt/secret.key"
if [[ ! -f $envcrypt_key_path ]]; then
  mkdir -p $(dirname $envcrypt_key_path)
  # Replace with your preferred key storage method
  echo $(op item get your-item-reference --fields password) > $envcrypt_key_path
  chmod 600 $envcrypt_key_path
fi

# Load encrypted environment variables if envcrypt is installed
if command -v envcrypt &> /dev/null; then
  set -a  # automatically export all variables
  eval "$(envcrypt decrypt $HOME/.env.enc)"
  set +a  # stop automatically exporting
fi
```
