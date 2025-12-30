# frozen_string_literal: true

# Read version from core gem directly (for build time)
core_version_path = File.expand_path("../core/lib/dotenvcrypt/core/version.rb", __dir__)
version_contents = File.read(core_version_path)
version = version_contents.match(/VERSION = ["'](.+)["']/)[1]

Gem::Specification.new do |spec|
  spec.name          = "dotenvcrypt"
  spec.version       = version
  spec.authors       = ["Dan Loman"]
  spec.email         = ["daniel.loman@gmail.com"]

  spec.summary       = "Securely encrypt, manage, and store your .env files in Git"
  spec.description   = "dotenvcrypt ensures your .env files - and, by extension, any secrets within them - are encrypted, enabling storage of these files directly within Git."
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

  # Core library dependency
  spec.add_dependency "dotenvcrypt-core", version

  # CLI dependencies
  spec.add_dependency "tty-prompt", "~> 0.23.1"
  spec.add_dependency "tty-command", "~> 0.10.1"
end
