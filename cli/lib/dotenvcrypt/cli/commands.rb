# frozen_string_literal: true

require 'tempfile'

module Dotenvcrypt
  module CLI
    class Commands
      def initialize(key:)
        @key = key
        @encryptor = Dotenvcrypt::Core::Encryptor.new(key)
      end

      # Encrypt an existing `.env` file
      def encrypt_file(unencrypted_file, encrypted_file)
        unless File.exist?(unencrypted_file)
          puts "❌ File not found: #{unencrypted_file}"
          exit(1)
        end

        encrypted_data = @encryptor.encrypt(File.read(unencrypted_file))
        File.write(encrypted_file, encrypted_data)

        puts "🔒 Encrypted #{unencrypted_file} → #{encrypted_file}"
      rescue Dotenvcrypt::Core::EncryptionError => e
        puts "❌ Encryption failed: #{e.message}"
        exit(1)
      end

      # Decrypt an encrypted `.env` file and print to stdout
      def decrypt_file(encrypted_file)
        unless File.exist?(encrypted_file)
          puts "❌ File not found: #{encrypted_file}"
          exit(1)
        end

        decrypted_content = @encryptor.decrypt(File.read(encrypted_file))
        puts decrypted_content
      rescue Dotenvcrypt::Core::DecryptionError => e
        puts "❌ Decryption failed: #{e.message}"
        exit(1)
      rescue Dotenvcrypt::Core::InvalidFormatError => e
        puts "❌ #{e.message}"
        exit(1)
      end

      # Edit decrypted env, then re-encrypt
      def edit_file(encrypted_file)
        unless File.exist?(encrypted_file)
          puts "❌ File not found: #{encrypted_file}"
          exit(1)
        end

        temp_file = Tempfile.new('dotenvcrypt')

        begin
          original_content = @encryptor.decrypt(File.read(encrypted_file))

          File.write(temp_file.path, original_content)

          puts "Waiting for file to be saved. Abort with Ctrl-C."

          system("#{ENV['EDITOR'] || 'vim'} #{temp_file.path}")

          updated_content = File.read(temp_file.path)

          if updated_content != original_content
            encrypted_data = @encryptor.encrypt(updated_content)
            File.write(encrypted_file, encrypted_data)
          end

          puts "🔒 Encrypted and saved #{encrypted_file}"
        rescue Dotenvcrypt::Core::DecryptionError => e
          puts "❌ Decryption failed: #{e.message}"
          exit(1)
        rescue Dotenvcrypt::Core::EncryptionError => e
          puts "❌ Encryption failed: #{e.message}"
          exit(1)
        rescue Dotenvcrypt::Core::InvalidFormatError => e
          puts "❌ #{e.message}"
          exit(1)
        ensure
          temp_file.unlink if temp_file
        end
      end
    end
  end
end
