# frozen_string_literal: true

# For development/monorepo: try to load from relative path first
begin
  require_relative '../../core/lib/dotenvcrypt-core'
rescue LoadError
  # For gem installation: load from installed dotenvcrypt-core gem
  require 'dotenvcrypt-core'
end

require 'tty-prompt'
require 'tty-command'
require_relative 'dotenvcrypt/version'
require_relative 'dotenvcrypt/cli/key_manager'
require_relative 'dotenvcrypt/cli/commands'

module Dotenvcrypt
  # Re-export core functionality (if not already defined)
  Core = Dotenvcrypt::Core unless defined?(Core)

  # Convenience method for library usage
  def self.load_env(encrypted_file_path, key:)
    Core.load_env(encrypted_file_path, key: key)
  end
end
