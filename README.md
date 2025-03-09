# EnvCrypt 🛡️🔐

**Securely encrypt, manage, and load your `.env` files in public repositories.**

> Inspired by `rails credentials`, `envcrypt` ensures your API keys are encrypted while keeping workflow simple.

---

## 🚀 Features

✅ Encrypt `.env` files into `.env.enc` for safe storage in Git.
✅ Load environment variables securely into the shell.
✅ Edit encrypted `.env.enc`, then re-encrypt after saving.
✅ Pass encryption keys via CLI `--key` or interactive prompt.

---

## 📦 Installation

### Using Homebrew (recommended)

```bash
brew install namolnad/formulae/envcrypt
