# frozen_string_literal: true

require 'rake/testtask'

desc 'Run tests for all gems'
task :test do
  puts "\n=== Running tests for dotenvcrypt-core ==="
  Dir.chdir('core') do
    sh 'bundle exec rake test'
  end

  puts "\n=== Running tests for dotenvcrypt (CLI) ==="
  Dir.chdir('cli') do
    sh 'bundle exec rake test'
  end
end

desc 'Build both gems'
task :build do
  puts "\n=== Building dotenvcrypt-core ==="
  Dir.chdir('core') do
    sh 'gem build dotenvcrypt-core.gemspec'
  end

  puts "\n=== Building dotenvcrypt (CLI) ==="
  Dir.chdir('cli') do
    sh 'gem build dotenvcrypt.gemspec'
  end

  puts "\n✅ Both gems built successfully!"
  puts 'Core gem: core/dotenvcrypt-core-*.gem'
  puts 'CLI gem:  cli/dotenvcrypt-*.gem'
end

desc 'Release both gems (build, tag, push to RubyGems)'
task :release do
  require_relative 'core/lib/dotenvcrypt/core/version'
  version = Dotenvcrypt::Core::VERSION

  puts "\n=== Releasing version #{version} ==="
  puts 'This will:'
  puts '  1. Build both gems'
  puts "  2. Create a git tag v#{version}"
  puts '  3. Push the tag to GitHub'
  puts '  4. Push both gems to RubyGems'
  puts ''

  # Confirm before releasing
  print 'Continue? (y/N): '
  response = STDIN.gets.chomp

  abort '❌ Release cancelled' unless response.downcase == 'y'

  # Release core first (CLI depends on it)
  puts "\n=== Releasing dotenvcrypt-core #{version} ==="
  Dir.chdir('core') do
    sh 'bundle exec rake release'
  end

  puts "\n=== Releasing dotenvcrypt (CLI) #{version} ==="
  Dir.chdir('cli') do
    sh 'bundle exec rake release'
  end

  puts "\n✅ Both gems released successfully!"
  puts "🎉 Version #{version} is now live on RubyGems!"
end

desc 'Clean built gems'
task :clean do
  puts 'Cleaning built gems...'
  FileUtils.rm_f(Dir.glob('core/*.gem'))
  FileUtils.rm_f(Dir.glob('cli/*.gem'))
  puts '✅ Clean complete'
end

desc 'Install both gems locally'
task install: :build do
  require_relative 'core/lib/dotenvcrypt/core/version'
  version = Dotenvcrypt::Core::VERSION

  core_gem = "core/dotenvcrypt-core-#{version}.gem"
  cli_gem = "cli/dotenvcrypt-#{version}.gem"

  puts "\n=== Installing dotenvcrypt-core locally ==="
  sh "gem install #{core_gem}"

  puts "\n=== Installing dotenvcrypt (CLI) locally ==="
  sh "gem install #{cli_gem}"

  puts "\n✅ Both gems installed locally!"
end

desc 'Bundle install for all gems'
task :bundle do
  puts "\n=== Bundle install for dotenvcrypt-core ==="
  Dir.chdir('core') do
    sh 'bundle install'
  end

  puts "\n=== Bundle install for dotenvcrypt (CLI) ==="
  Dir.chdir('cli') do
    sh 'bundle install'
  end

  puts "\n✅ Bundle install complete for all gems!"
end

task default: :test
