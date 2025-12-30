# frozen_string_literal: true

require_relative "lib/dotenvcrypt/core/version"

Gem::Specification.new do |spec|
  spec.name          = "dotenvcrypt-core"
  spec.version       = Dotenvcrypt::Core::VERSION
  spec.authors       = ["Dan Loman"]
  spec.email         = ["daniel.loman@gmail.com"]

  spec.summary       = "Core encryption/decryption library for dotenvcrypt"
  spec.description   = "Pure Ruby library for encrypting and decrypting .env files using AES-256-GCM"
  spec.homepage      = "https://github.com/namolnad/dotenvcrypt"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.glob("lib/**/*") + %w[LICENSE README.md]
  spec.require_paths = ["lib"]

  # No runtime dependencies - pure stdlib
end
