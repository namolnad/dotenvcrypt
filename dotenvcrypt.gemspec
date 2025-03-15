# frozen_string_literal: true
require_relative "lib/dotenvcrypt/version"

Gem::Specification.new do |spec|
  spec.name          = "dotenvcrypt"
  spec.version       = Dotenvcrypt::VERSION
  spec.authors       = ["Dan Loman"]
  spec.email         = ["daniel.loman@gmail.com"]

  spec.summary       = "Securely encrypt, manage, and store your .env files in Git"
  spec.description   = "dotenvcrypt ensures any API keys in your .env files are encrypted - enabling storage of these files directly within Git."
  spec.homepage      = "https://github.com/namolnad/dotenvcrypt"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{bin,lib}/**/*") + %w[LICENSE README.md]
  spec.bindir        = "bin"
  spec.executables   = ["dotenvcrypt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-prompt", "~> 0.23.1"
  spec.add_dependency "tty-command", "~> 0.10.1"
end

