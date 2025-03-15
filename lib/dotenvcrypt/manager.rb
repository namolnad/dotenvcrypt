# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'tty-prompt'
require 'tty-command'
require 'tempfile'
require 'optparse'

module Dotenvcrypt
  class Manager
    # Determine config directory following XDG Base Directory Specification
    CONFIG_HOME = ENV['XDG_CONFIG_HOME'] || "#{ENV['HOME']}/.config"
    CONFIG_DIR = "#{CONFIG_HOME}/dotenvcrypt".freeze

    # Check multiple locations in order of preference
    ENCRYPTION_KEY_LOCATIONS = [
      "#{Dir.pwd}/.dotenvcrypt.key",             # Project-specific key (current directory)
      "#{CONFIG_DIR}/secret.key",                # XDG standard location
      "#{ENV['HOME']}/.dotenvcrypt.key"          # Legacy location (for backward compatibility)
    ].freeze

    def initialize(encryption_key = nil)
      @encryption_key = encryption_key
    end

    # Encrypt an existing `.env` file
    def encrypt_env(unencrypted_file, encrypted_file)
      unless File.exist?(unencrypted_file)
        puts "❌ File not found: #{unencrypted_file}"
        exit(1)
      end

      encrypt(unencrypted_file, encrypted_file)

      puts "🔒 Encrypted #{unencrypted_file} → #{encrypted_file}"
    end

    # Decrypt an encrypted `.env` file and print to stdout
    def decrypt_env(encrypted_file)
      puts decrypt(encrypted_file)
    end

    # Edit decrypted env, then re-encrypt
    def edit_env(encrypted_file)
      temp_file = Tempfile.new('dotenvcrypt')

      File.open(temp_file.path, 'w') do |f|
        f.write decrypt(encrypted_file)
      end

      puts "Waiting for file to be saved. Abort with Ctrl-C."

      system("#{ENV['EDITOR'] || 'vim'} #{temp_file.path}")

      encrypt(temp_file.path, encrypted_file)

      puts "🔒 Encrypted and saved #{encrypted_file}"
    ensure
      temp_file.unlink if temp_file
    end

    private

    attr_reader :encryption_key

    # Encrypt file
    def encrypt(input_file, output_file)
      cipher = OpenSSL::Cipher::AES256.new(:GCM)
      cipher.encrypt
      key = OpenSSL::Digest::SHA256.digest(fetch_key)
      cipher.key = key

      # Generate a secure random IV (12 bytes is recommended for GCM)
      iv = cipher.random_iv

      data = File.read(input_file)
      encrypted = cipher.update(data) + cipher.final

      # Get the authentication tag (16 bytes)
      auth_tag = cipher.auth_tag

      # Combine IV, encrypted data, and auth tag
      combined = iv + auth_tag + encrypted

      # Convert to base64 for readability
      base64_data = Base64.strict_encode64(combined)

      File.open(output_file, 'w') do |f|
        f.write(base64_data)
      end
    end

    # Decrypt file
    def decrypt(input_file)
      # Read the encrypted file
      begin
        base64_data = File.read(input_file)
        data = Base64.strict_decode64(base64_data)
      rescue ArgumentError
        puts "❌ Decryption failed. File is not in valid base64 format."
        exit(1)
      end

      # For GCM mode:
      # - IV is 12 bytes
      # - Auth tag is 16 bytes
      iv_size = 12
      auth_tag_size = 16

      # Extract the components
      iv = data[0...iv_size]
      auth_tag = data[iv_size...(iv_size + auth_tag_size)]
      encrypted_data = data[(iv_size + auth_tag_size)..-1]

      cipher = OpenSSL::Cipher::AES256.new(:GCM)
      cipher.decrypt
      cipher.key = OpenSSL::Digest::SHA256.digest(fetch_key)
      cipher.iv = iv
      cipher.auth_tag = auth_tag

      cipher.update(encrypted_data) + cipher.final
    rescue OpenSSL::Cipher::CipherError
      puts "❌ Decryption failed. Invalid key, corrupted file, or tampering detected."
      exit(1)
    end

    # Get encryption key: From CLI arg OR encryption-key file OR securely prompt from stdin
    def fetch_key
      return encryption_key if encryption_key && !encryption_key.empty?
      return ENV['DOTENVCRYPT_KEY'] if ENV['DOTENVCRYPT_KEY'] && !ENV['DOTENVCRYPT_KEY'].empty?
      ENCRYPTION_KEY_LOCATIONS.each do |key_file|
        return File.read(key_file).strip if File.exist?(key_file)
      end

      prompt.ask("Enter encryption key:", echo: false)
    end

    def prompt
      @prompt ||= TTY::Prompt.new
    end
  end
end

