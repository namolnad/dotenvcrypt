# frozen_string_literal: true

require "test_helper"

class EnvLoaderTest < Minitest::Test
  def setup
    @key = "test-key"
    @encryptor = Dotenvcrypt::Core::Encryptor.new(@key)
    @temp_file = Tempfile.new(['test', '.env.enc'])

    # Store original ENV values to restore later
    @original_env = ENV.to_h.dup
  end

  def teardown
    @temp_file.unlink if @temp_file

    # Restore original ENV and clean up test vars
    ENV.clear
    ENV.update(@original_env)
  end

  def test_load_env_basic
    env_content = "DATABASE_URL=postgres://localhost/mydb\nAPI_KEY=secret123"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    result = Dotenvcrypt::Core::EnvLoader.load_env(@temp_file.path, key: @key)

    assert_equal "postgres://localhost/mydb", ENV['DATABASE_URL']
    assert_equal "secret123", ENV['API_KEY']
    assert_equal({"DATABASE_URL" => "postgres://localhost/mydb", "API_KEY" => "secret123"}, result)
  end

  def test_load_env_skips_comments
    env_content = "# This is a comment\nVALID_KEY=value\n# Another comment"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    result = Dotenvcrypt::Core::EnvLoader.load_env(@temp_file.path, key: @key)

    assert_equal "value", ENV['VALID_KEY']
    assert_equal 1, result.size
  end

  def test_load_env_skips_empty_lines
    env_content = "KEY1=value1\n\n\nKEY2=value2\n"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    result = Dotenvcrypt::Core::EnvLoader.load_env(@temp_file.path, key: @key)

    assert_equal "value1", ENV['KEY1']
    assert_equal "value2", ENV['KEY2']
    assert_equal 2, result.size
  end

  def test_load_env_handles_quoted_values
    env_content = "SINGLE='single quoted'\nDOUBLE=\"double quoted\"\nNONE=not quoted"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    Dotenvcrypt::Core::EnvLoader.load_env(@temp_file.path, key: @key)

    assert_equal "single quoted", ENV['SINGLE']
    assert_equal "double quoted", ENV['DOUBLE']
    assert_equal "not quoted", ENV['NONE']
  end

  def test_load_env_with_spaces_around_equals
    env_content = "KEY1 = value1\nKEY2= value2\nKEY3 =value3"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    Dotenvcrypt::Core::EnvLoader.load_env(@temp_file.path, key: @key)

    # Spaces are preserved as part of the value when on the right side
    assert_equal "value1", ENV['KEY1']
    assert_equal "value2", ENV['KEY2']
    assert_equal "value3", ENV['KEY3']
  end

  def test_load_env_raises_on_missing_file
    error = assert_raises(ArgumentError) do
      Dotenvcrypt::Core::EnvLoader.load_env("/nonexistent/file.enc", key: @key)
    end

    assert_match(/File not found/, error.message)
  end

  def test_load_env_raises_on_wrong_key
    env_content = "KEY=value"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    assert_raises(Dotenvcrypt::Core::DecryptionError) do
      Dotenvcrypt::Core::EnvLoader.load_env(@temp_file.path, key: "wrong-key")
    end
  end

  def test_load_env_via_module_method
    env_content = "MODULE_TEST=success"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    result = Dotenvcrypt::Core.load_env(@temp_file.path, key: @key)

    assert_equal "success", ENV['MODULE_TEST']
    assert_equal({"MODULE_TEST" => "success"}, result)
  end

  def test_load_env_via_top_level_method
    env_content = "TOP_LEVEL_TEST=success"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    result = Dotenvcrypt.load_env(@temp_file.path, key: @key)

    assert_equal "success", ENV['TOP_LEVEL_TEST']
    assert_equal({"TOP_LEVEL_TEST" => "success"}, result)
  end

  def test_load_env_overwrites_existing_values
    ENV['EXISTING_KEY'] = 'old_value'

    env_content = "EXISTING_KEY=new_value"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    Dotenvcrypt::Core::EnvLoader.load_env(@temp_file.path, key: @key)

    assert_equal "new_value", ENV['EXISTING_KEY']
  end

  def test_load_env_with_empty_value
    env_content = "EMPTY_VALUE="
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    result = Dotenvcrypt::Core::EnvLoader.load_env(@temp_file.path, key: @key)

    assert_equal "", ENV['EMPTY_VALUE']
    assert_equal({"EMPTY_VALUE" => ""}, result)
  end

  def test_load_env_ignores_invalid_lines
    env_content = "VALID=value\ninvalid line without equals\nANOTHER_VALID=value2"
    @temp_file.write(@encryptor.encrypt(env_content))
    @temp_file.rewind

    result = Dotenvcrypt::Core::EnvLoader.load_env(@temp_file.path, key: @key)

    assert_equal "value", ENV['VALID']
    assert_equal "value2", ENV['ANOTHER_VALID']
    assert_equal 2, result.size
  end
end
