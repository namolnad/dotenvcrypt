# frozen_string_literal: true

require 'base64'
require 'openssl'
require_relative 'core/version'
require_relative 'core/encryptor'
require_relative 'core/env_loader'

module Dotenvcrypt
  module Core
    # Convenience method for loading encrypted env files
    def self.load_env(encrypted_file_path, key:)
      EnvLoader.load_env(encrypted_file_path, key: key)
    end
  end

  # Also expose load_env at the top level for convenience
  def self.load_env(encrypted_file_path, key:)
    Core.load_env(encrypted_file_path, key: key)
  end
end
