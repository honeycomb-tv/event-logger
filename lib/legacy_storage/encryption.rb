class LegacyStorage::Encryption

  def initialize(opts)
    @public_key = OpenSSL::PKey::RSA.new(File.read(opts[:public_key_path]))
    @private_key = OpenSSL::PKey::RSA.new(File.read(opts[:private_key_path]), opts[:private_key_password])
  end

  def encrypt(bytes)
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    aes_key = cipher.random_key
    iv = cipher.random_iv
    encrypted_bytes = ''
    offset = 0
    while offset < bytes.length
      length = offset + 4096 > bytes.length ? bytes.length - offset : 4096
      encrypted_bytes << cipher.update(bytes[offset,length])
      offset += length
    end
    encrypted_bytes << cipher.final
    {
      bytes: encrypted_bytes,
      encrypted_key: @public_key.public_encrypt(aes_key),
      encryption_iv: iv
    }
  end

  def decrypt(encrypted_bytes, encrypted_key, encryption_iv)
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.decrypt
    cipher.key = @private_key.private_decrypt(encrypted_key)
    cipher.iv = encryption_iv
    bytes = ''
    offset = 0
    while offset < encrypted_bytes.length
      length = offset + 4096 > encrypted_bytes.length ? encrypted_bytes.length - offset : 4096
      bytes << cipher.update(encrypted_bytes[offset,length])
      offset += length
    end
    bytes << cipher.final
    bytes
  end

end
