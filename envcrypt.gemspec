# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "envcrypt"
  spec.version       = "0.1.0"
  spec.authors       = ["Dan Loman"]
  spec.email         = ["daniel.loman@gmail.com"]

  spec.summary       = "Securely encrypt, manage, and load your .env files in public repositories"
  spec.description   = "EnvCrypt ensures your API keys are encrypted while keeping workflow simple"
  spec.homepage      = "https://github.com/namolnad/envcrypt"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{bin,lib}/**/*") + %w[LICENSE README.md]
  spec.bindir        = "bin"
  spec.executables   = ["envcrypt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-prompt", "~> 0.23.1"
  spec.add_dependency "tty-command", "~> 0.10.1"
end

