module Dotenvcrypt
  class Encryptor
    def initialize(encryption_key)
      @encryption_key = encryption_key
    end

    # Encrypt file
    def encrypt(data)
      cipher = OpenSSL::Cipher::AES256.new(:GCM)
      cipher.encrypt
      key = OpenSSL::Digest::SHA256.digest(encryption_key)
      cipher.key = key

      # Generate a secure random IV (12 bytes is recommended for GCM)
      iv = cipher.random_iv

      encrypted = cipher.update(data) + cipher.final

      # Get the authentication tag (16 bytes)
      auth_tag = cipher.auth_tag

      # Combine IV, encrypted data, and auth tag
      combined = iv + auth_tag + encrypted

      # Convert to base64 for readability
      Base64.strict_encode64(combined)
    end

    # Decrypt file
    def decrypt(base64_data)
      # Read the encrypted file
      begin
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
      cipher.key = OpenSSL::Digest::SHA256.digest(encryption_key)
      cipher.iv = iv
      cipher.auth_tag = auth_tag

      cipher.update(encrypted_data) + cipher.final
    rescue OpenSSL::Cipher::CipherError
      puts "❌ Decryption failed. Invalid key, corrupted file, or tampering detected."
      exit(1)
    end

    private

    attr_reader :encryption_key
  end
end
