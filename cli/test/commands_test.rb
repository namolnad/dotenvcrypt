# frozen_string_literal: true

require "test_helper"

class CommandsTest < Minitest::Test
  def setup
    @key = "test-key"
    @commands = Dotenvcrypt::CLI::Commands.new(key: @key)
    @temp_dir = Dir.mktmpdir
    @unencrypted_file = File.join(@temp_dir, "test.env")
    @encrypted_file = File.join(@temp_dir, "test.env.enc")
  end

  def teardown
    FileUtils.rm_rf(@temp_dir)
  end

  def test_encrypt_file_creates_encrypted_file
    File.write(@unencrypted_file, "SECRET=value123")

    # Capture output
    output = capture_io do
      @commands.encrypt_file(@unencrypted_file, @encrypted_file)
    end

    assert File.exist?(@encrypted_file)
    assert_match(/Encrypted.*test\.env.*test\.env\.enc/, output.join)

    # Verify it can be decrypted
    encryptor = Dotenvcrypt::Core::Encryptor.new(@key)
    decrypted = encryptor.decrypt(File.read(@encrypted_file))
    assert_equal "SECRET=value123", decrypted
  end

  def test_encrypt_file_exits_on_missing_file
    assert_exit_with_code(1) do
      capture_io do
        @commands.encrypt_file("/nonexistent/file.env", @encrypted_file)
      end
    end
  end

  def test_decrypt_file_outputs_decrypted_content
    # First encrypt a file
    File.write(@unencrypted_file, "KEY1=value1\nKEY2=value2")
    encryptor = Dotenvcrypt::Core::Encryptor.new(@key)
    File.write(@encrypted_file, encryptor.encrypt(File.read(@unencrypted_file)))

    output = capture_io do
      @commands.decrypt_file(@encrypted_file)
    end

    assert_match(/KEY1=value1/, output.join)
    assert_match(/KEY2=value2/, output.join)
  end

  def test_decrypt_file_exits_on_missing_file
    assert_exit_with_code(1) do
      capture_io do
        @commands.decrypt_file("/nonexistent/file.enc")
      end
    end
  end

  def test_decrypt_file_exits_on_wrong_key
    # Encrypt with one key
    File.write(@unencrypted_file, "SECRET=value")
    encryptor1 = Dotenvcrypt::Core::Encryptor.new("correct-key")
    File.write(@encrypted_file, encryptor1.encrypt(File.read(@unencrypted_file)))

    # Try to decrypt with wrong key
    wrong_commands = Dotenvcrypt::CLI::Commands.new(key: "wrong-key")

    assert_exit_with_code(1) do
      capture_io do
        wrong_commands.decrypt_file(@encrypted_file)
      end
    end
  end

  def test_edit_file_updates_encrypted_file
    skip "Skipping interactive edit test - requires editor setup"

    # This test would require mocking the system editor call
    # Left as a placeholder for future implementation
  end

  def test_edit_file_exits_on_missing_file
    assert_exit_with_code(1) do
      capture_io do
        @commands.edit_file("/nonexistent/file.enc")
      end
    end
  end

  private

  def assert_exit_with_code(code)
    # Minitest doesn't have built-in exit code testing
    # We'll verify the method calls exit(1) by checking if it raises SystemExit
    error = assert_raises(SystemExit) do
      yield
    end

    assert_equal code, error.status
  end
end
