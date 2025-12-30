# frozen_string_literal: true

require "test_helper"

class EncryptorTest < Minitest::Test
  def setup
    @key = "test-encryption-key"
    @encryptor = Dotenvcrypt::Core::Encryptor.new(@key)
  end

  def test_encrypt_returns_base64_string
    data = "SECRET=my-secret-value"
    encrypted = @encryptor.encrypt(data)

    assert_kind_of String, encrypted
    # Should be valid base64
    assert_match(/\A[A-Za-z0-9+\/]+=*\z/, encrypted)
  end

  def test_decrypt_returns_original_data
    original = "DATABASE_URL=postgres://localhost/db\nAPI_KEY=abc123"
    encrypted = @encryptor.encrypt(original)
    decrypted = @encryptor.decrypt(encrypted)

    assert_equal original, decrypted
  end

  def test_encrypt_decrypt_round_trip
    test_cases = [
      "simple text",
      "multi\nline\ntext",
      "special chars: !@#$%^&*()",
      "KEY=value",
      ""
    ]

    test_cases.each do |data|
      encrypted = @encryptor.encrypt(data)
      decrypted = @encryptor.decrypt(encrypted)
      assert_equal data, decrypted, "Failed for: #{data.inspect}"
    end
  end

  def test_different_keys_produce_different_ciphertexts
    data = "SECRET=value"
    encryptor1 = Dotenvcrypt::Core::Encryptor.new("key1")
    encryptor2 = Dotenvcrypt::Core::Encryptor.new("key2")

    encrypted1 = encryptor1.encrypt(data)
    encrypted2 = encryptor2.encrypt(data)

    refute_equal encrypted1, encrypted2
  end

  def test_decrypt_with_wrong_key_raises_error
    data = "SECRET=value"
    encrypted = @encryptor.encrypt(data)

    wrong_encryptor = Dotenvcrypt::Core::Encryptor.new("wrong-key")

    error = assert_raises(Dotenvcrypt::Core::DecryptionError) do
      wrong_encryptor.decrypt(encrypted)
    end

    assert_match(/Invalid key, corrupted file, or tampering detected/, error.message)
  end

  def test_decrypt_invalid_base64_raises_error
    invalid_base64 = "not-valid-base64!!!"

    error = assert_raises(Dotenvcrypt::Core::InvalidFormatError) do
      @encryptor.decrypt(invalid_base64)
    end

    assert_match(/not in valid base64 format/, error.message)
  end

  def test_decrypt_tampered_data_raises_error
    data = "SECRET=value"
    encrypted = @encryptor.encrypt(data)

    # Tamper with the encrypted data
    tampered = encrypted.chars.rotate(5).join

    assert_raises(Dotenvcrypt::Core::DecryptionError) do
      @encryptor.decrypt(tampered)
    end
  end

  def test_same_plaintext_produces_different_ciphertexts
    # Due to random IV, encrypting the same data twice should produce different results
    data = "SECRET=value"
    encrypted1 = @encryptor.encrypt(data)
    encrypted2 = @encryptor.encrypt(data)

    refute_equal encrypted1, encrypted2
  end

  def test_empty_string_encryption
    encrypted = @encryptor.encrypt("")
    decrypted = @encryptor.decrypt(encrypted)

    assert_equal "", decrypted
  end

  def test_large_data_encryption
    large_data = "KEY=VALUE\n" * 1000
    encrypted = @encryptor.encrypt(large_data)
    decrypted = @encryptor.decrypt(encrypted)

    assert_equal large_data, decrypted
  end
end
