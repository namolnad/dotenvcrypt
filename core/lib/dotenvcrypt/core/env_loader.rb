# frozen_string_literal: true

module Dotenvcrypt
  module Core
    class EnvLoader
      def self.load_env(encrypted_file_path, key:)
        raise ArgumentError, "File not found: #{encrypted_file_path}" unless File.exist?(encrypted_file_path)

        # Read and decrypt
        encrypted_data = File.read(encrypted_file_path)
        encryptor = Encryptor.new(key)
        decrypted_content = encryptor.decrypt(encrypted_data)

        # Parse and load into ENV
        parse_and_load_env(decrypted_content)
      end

      private

      def self.parse_and_load_env(content)
        loaded = {}

        content.each_line do |line|
          line = line.strip

          # Skip comments and empty lines
          next if line.empty? || line.start_with?('#')

          # Parse KEY=value format
          if line =~ /\A([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\z/
            key = $1
            value = $2

            # Remove surrounding quotes if present (single or double)
            value = value.gsub(/\A["']|["']\z/, '')

            # Load into ENV
            ENV[key] = value
            loaded[key] = value
          end
        end

        loaded
      end
    end
  end
end
