require 'aws-sdk'

class LegacyStorage::S3Storage

  def initialize(args)
    @s3 = AWS::S3.new(:access_key_id => args[:access_key], :secret_access_key => args[:secret_key], :region => args[:region])
    @bucket = @s3.buckets[args[:bucket]]
    @encryption = LegacyStorage::Encryption.new(args[:encryption])
  end

  def store_chunk(parent_id, id, bytes)
    encrypted = @encryption.encrypt(bytes)
    key = File.join(parent_id.to_s, id.to_s)
    obj = @bucket.objects[key]
    obj.write(StringIO.new(encrypted[:bytes], 'rb'))
    obj = @bucket.objects["#{key}.key"]
    obj.write(encrypted[:encrypted_key], metadata: {encryption_iv: Base64.encode64(encrypted[:encryption_iv])})
  end

  def retrieve_chunk(parent_id, id)
    key = File.join(parent_id.to_s, id.to_s)
    obj = @bucket.objects[key]
    encrypted_bytes = ""
    StringIO.open(encrypted_bytes, 'wb') do |s|
      obj.read do |o|
        s.write(o)
      end
    end
    obj = @bucket.objects["#{key}.key"]
    encrypted_key = obj.read
    encryption_iv = Base64.decode64(obj.metadata[:encryption_iv])
    @encryption.decrypt(encrypted_bytes, encrypted_key, encryption_iv)
  rescue AWS::S3::Errors::NoSuchKey
    raise ChunkNotFoundException.new
  end

  def delete_chunk(parent_id, id)
    key = File.join(parent_id.to_s, id.to_s)
    obj = @bucket.objects[key]
    obj.delete if obj.exists?
  end
end
