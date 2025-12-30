# dotenvcrypt-core

Pure Ruby library for encrypting and decrypting .env files using AES-256-GCM encryption.

## Installation

```bash
gem install dotenvcrypt-core
```

Or add to your Gemfile:

```ruby
gem 'dotenvcrypt-core'
```

## Usage

### Loading Encrypted ENV Files

The simplest way to use dotenvcrypt-core is to load an encrypted .env file directly into your environment:

```ruby
require 'dotenvcrypt-core'

# Load encrypted .env file into ENV
Dotenvcrypt.load_env('.env.enc', key: 'your-secret-key')

# Now you can access your environment variables
puts ENV['DATABASE_URL']
```

### Encrypting and Decrypting Manually

For more control, you can use the Encryptor class directly:

```ruby
require 'dotenvcrypt-core'

# Create an encryptor with your secret key
encryptor = Dotenvcrypt::Core::Encryptor.new('your-secret-key')

# Encrypt data
plaintext = "SECRET_KEY=my-secret-value\nAPI_TOKEN=abc123"
encrypted = encryptor.encrypt(plaintext)
File.write('.env.enc', encrypted)

# Decrypt data
encrypted_data = File.read('.env.enc')
decrypted = encryptor.decrypt(encrypted_data)
puts decrypted
```

### Error Handling

The library raises exceptions instead of printing to stdout or exiting:

```ruby
begin
  Dotenvcrypt.load('.env.enc', key: 'wrong-key')
rescue Dotenvcrypt::Core::DecryptionError => e
  puts "Failed to decrypt: #{e.message}"
rescue Dotenvcrypt::Core::InvalidFormatError => e
  puts "Invalid file format: #{e.message}"
end
```

Available exceptions:
- `Dotenvcrypt::Core::EncryptionError` - General encryption errors
- `Dotenvcrypt::Core::DecryptionError` - Decryption failed (wrong key, corrupted file, tampering)
- `Dotenvcrypt::Core::InvalidFormatError` - File is not in valid base64 format

## Features

- **AES-256-GCM encryption** - Industry-standard authenticated encryption
- **Pure Ruby** - No external dependencies beyond Ruby's standard library
- **Exception-based error handling** - Integrate cleanly into your application
- **Dotenv-compatible** - Works with standard .env file format

## Security

- Uses AES-256 in GCM (Galois/Counter Mode) for authenticated encryption
- Generates secure random initialization vectors (IV) for each encryption
- Provides tamper detection via authentication tags
- Keys are hashed with SHA256 before use

## License

MIT
