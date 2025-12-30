# frozen_string_literal: true

require 'tty-prompt'

module Dotenvcrypt
  module CLI
    class KeyManager
      # Determine config directory following XDG Base Directory Specification
      CONFIG_HOME = ENV['XDG_CONFIG_HOME'] || "#{ENV['HOME']}/.config"
      CONFIG_DIR = "#{CONFIG_HOME}/dotenvcrypt".freeze

      # Check multiple locations in order of preference
      ENCRYPTION_KEY_LOCATIONS = [
        "#{Dir.pwd}/.dotenvcrypt.key",             # Project-specific key (current directory)
        "#{CONFIG_DIR}/secret.key",                # XDG standard location
        "#{ENV['HOME']}/.dotenvcrypt.key"          # Legacy location (for backward compatibility)
      ].freeze

      def self.fetch_key(cli_key = nil)
        return cli_key if cli_key && !cli_key.empty?
        return ENV['DOTENVCRYPT_KEY'] if ENV['DOTENVCRYPT_KEY'] && !ENV['DOTENVCRYPT_KEY'].empty?

        ENCRYPTION_KEY_LOCATIONS.each do |key_file|
          return File.read(key_file).strip if File.exist?(key_file)
        end

        TTY::Prompt.new.ask("Enter encryption key:", echo: false)
      end
    end
  end
end
