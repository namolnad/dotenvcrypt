# frozen_string_literal: true

# During gem build or in monorepo: read version from core directly
core_version_file = File.expand_path('../../core/lib/dotenvcrypt/core/version.rb', __dir__)
if File.exist?(core_version_file)
  # Load from monorepo structure
  require_relative '../../core/lib/dotenvcrypt/core/version'
else
  # For gem installation: load from installed dotenvcrypt-core gem
  require 'dotenvcrypt/core/version'
end

module Dotenvcrypt
  VERSION = Core::VERSION
end
