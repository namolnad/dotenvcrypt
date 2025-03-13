# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'tty-prompt'
require 'tty-command'
require 'tempfile'
require 'optparse'

module Envcrypt
  class Manager
    # Determine config directory following XDG Base Directory Specification
    CONFIG_HOME = ENV['XDG_CONFIG_HOME'] || "#{ENV['HOME']}/.config"
    CONFIG_DIR = "#{CONFIG_HOME}/envcrypt".freeze

    # Check multiple locations in order of preference
    ENCRYPTION_KEY_LOCATIONS = [
      "#{Dir.pwd}/.envcrypt.key",                # Project-specific key (current directory)
      "#{CONFIG_DIR}/secret.key",                # XDG standard location
      "#{ENV['HOME']}/.envcrypt.key"             # Legacy location (for backward compatibility)
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
      temp_file = Tempfile.new('envcrypt')

      File.open(temp_file.path, 'w') do |f|
        f.write decrypt(encrypted_file)
      end

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
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.encrypt
      cipher.key = OpenSSL::Digest::SHA256.digest(fetch_key)

      # Generate a secure random IV (16 bytes for AES-256-CBC)
      iv = cipher.random_iv

      data = File.read(input_file)
      encrypted = cipher.update(data) + cipher.final

      File.open(output_file, 'wb') do |f|
        f.write(iv)
        f.write(encrypted)
      end
    end

    # Decrypt file
    def decrypt(input_file)
      # Read the encrypted file
      data = File.binread(input_file)

      # Extract the IV from the first 16 bytes
      iv = data[0...16]
      encrypted_data = data[16..-1]

      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.decrypt
      cipher.key = OpenSSL::Digest::SHA256.digest(fetch_key)
      cipher.iv = iv

      cipher.update(encrypted_data) + cipher.final
    rescue OpenSSL::Cipher::CipherError
      puts "❌ Decryption failed. Invalid key or corrupted file."
      exit(1)
    end

    # Get encryption key: From CLI arg OR encryption-key file OR securely prompt from stdin
    def fetch_key
      return encryption_key if encryption_key && !encryption_key.empty?
      return ENV['ENVCRYPT_KEY'] if ENV['ENVCYPT_KEY'] && !ENV['ENVCYPT_KEY'].empty?
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

