# frozen_string_literal: true

require "test_helper"

class KeyManagerTest < Minitest::Test
  def setup
    @original_env = ENV.to_h.dup
  end

  def teardown
    ENV.clear
    ENV.update(@original_env)
  end

  def test_fetch_key_from_cli_argument
    key = Dotenvcrypt::CLI::KeyManager.fetch_key("cli-provided-key")

    assert_equal "cli-provided-key", key
  end

  def test_fetch_key_from_env_var
    ENV['DOTENVCRYPT_KEY'] = "env-var-key"

    key = Dotenvcrypt::CLI::KeyManager.fetch_key(nil)

    assert_equal "env-var-key", key
  end

  def test_fetch_key_priority_cli_over_env
    ENV['DOTENVCRYPT_KEY'] = "env-key"

    key = Dotenvcrypt::CLI::KeyManager.fetch_key("cli-key")

    assert_equal "cli-key", key
  end

  def test_fetch_key_priority_env_over_file
    skip "Requires file system setup - tested in integration"
  end

  def test_fetch_key_ignores_empty_cli_argument
    ENV['DOTENVCRYPT_KEY'] = "env-key"

    key = Dotenvcrypt::CLI::KeyManager.fetch_key("")

    assert_equal "env-key", key
  end

  def test_fetch_key_ignores_empty_env_var
    skip "Requires file system setup - tested in integration"
  end

  def test_encryption_key_locations_constant_exists
    assert_kind_of Array, Dotenvcrypt::CLI::KeyManager::ENCRYPTION_KEY_LOCATIONS
    refute_empty Dotenvcrypt::CLI::KeyManager::ENCRYPTION_KEY_LOCATIONS
  end
end
