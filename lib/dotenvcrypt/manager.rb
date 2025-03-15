# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'tty-prompt'
require 'tty-command'
require 'tempfile'
require 'optparse'
require_relative 'encryptor'

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
      @encryptor = Encryptor.new(fetch_key)
    end

    # Encrypt an existing `.env` file
    def encrypt_file(unencrypted_file, encrypted_file)
      unless File.exist?(unencrypted_file)
        puts "❌ File not found: #{unencrypted_file}"
        exit(1)
      end

      File.open(encrypted_file, 'w') do |f|
        f.write encryptor.encrypt(File.read(unencrypted_file))
      end

      puts "🔒 Encrypted #{unencrypted_file} → #{encrypted_file}"
    end

    # Decrypt an encrypted `.env` file and print to stdout
    def decrypt_file(encrypted_file)
      puts encryptor.decrypt(File.read(encrypted_file))
    end

    # Edit decrypted env, then re-encrypt
    def edit_file(encrypted_file)
      temp_file = Tempfile.new('dotenvcrypt')

      File.open(temp_file.path, 'w') do |f|
        f.write encryptor.decrypt(File.read(encrypted_file))
      end

      puts "Waiting for file to be saved. Abort with Ctrl-C."

      system("#{ENV['EDITOR'] || 'vim'} #{temp_file.path}")

      File.open(encrypted_file, 'w') do |f|
        f.write encryptor.encrypt(File.read(temp_file.path))
      end

      puts "🔒 Encrypted and saved #{encrypted_file}"
    ensure
      temp_file.unlink if temp_file
    end

    private

    attr_reader :encryption_key, :encryptor

    # Get encryption key: From CLI arg OR encryption-key file OR securely prompt from stdin
    def fetch_key
      return encryption_key if encryption_key && !encryption_key.empty?
      return ENV['DOTENVCRYPT_KEY'] if ENV['DOTENVCRYPT_KEY'] && !ENV['DOTENVCRYPT_KEY'].empty?
      ENCRYPTION_KEY_LOCATIONS.each do |key_file|
        return File.read(key_file).strip if File.exist?(key_file)
      end

      TTY::Prompt.new.ask("Enter encryption key:", echo: false)
    end
  end
end

