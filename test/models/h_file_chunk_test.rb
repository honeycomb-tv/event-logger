require 'test_helper'

class HFileChunkTest < ActiveSupport::TestCase
  
  test 'Creation of chunk with valid SHA3 hash should succeed' do
    chunk = HFileChunk.new_or_duplicate(known_good_chunk)
    assert_not_nil(chunk)
  end
  
  test 'Creation of chunk with invalid SHA3 hash should fail' do
    chunk1 = known_good_chunk
    # puts "Chunk1 SHA3: #{chunk1[:sha3_digest_hex]}"
    chunk2 = known_good_chunk
    # puts "Chunk2 SHA3: #{chunk2[:sha3_digest_hex]}"
    chunk1[:sha3_digest_hex] = chunk2[:sha3_digest_hex]
    assert_raises(RuntimeError) do
      chunk = HFileChunk.new_or_duplicate(JSON.parse(chunk1.to_json))
    end
  end
  
  private
  
    def known_good_chunk
      bytes = random_bytes
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.encrypt
      aes_key = cipher.random_key
      iv = cipher.random_iv
      encrypted_bytes = ''
      src = StringIO.open(bytes, 'rb')
      dst = StringIO.open(encrypted_bytes, 'wb')
      until src.eof? do
        dst.write(cipher.update(src.read(4096)))
      end
      dst.write(cipher.final)
      public_key = OpenSSL::PKey::RSA.new(Server::Application.config.HONEYCOMB_PUBLIC_KEY)
      encrypted_key = public_key.public_encrypt(aes_key)
      {
        bytes64: Base64.encode64(encrypted_bytes),
        encryption_key: Base64.encode64(encrypted_key),
        encryption_iv: Base64.encode64(iv),
        sha3_digest_hex: Digest::SHA3.hexdigest(bytes)
      }
    end
    
    def random_bytes
      s = ''
      while s.length < 100000 do
        s << ('a'.ord + rand('z'.ord - 'a'.ord)).chr
      end
      s
    end
  
end
