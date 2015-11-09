require 'azure'

class LegacyStorage::AzureStorage

  DEFAULT_CONTAINER = 'chunks'

  def initialize(opts)
    Azure.config.storage_account_name = opts[:account_name]
    Azure.config.storage_access_key = opts[:access_key]
    @encryption = Storage::Encryption.new(opts[:encryption])
    @azure = Azure::BlobService.new
  end

  def store_chunk(parent_id, id, bytes)
    encrypted = @encryption.encrypt(bytes)
    key = File.join(parent_id.to_s, id.to_s)
    @azure.create_block_blob(DEFAULT_CONTAINER, key, encrypted[:bytes])
    @azure.create_block_blob(DEFAULT_CONTAINER, "#{key}.key", encrypted[:encrypted_key])
    @azure.create_block_blob(DEFAULT_CONTAINER, "#{key}.iv", encrypted[:encryption_iv])
  end

  def retrieve_chunk(parent_id, id)
    key = File.join(parent_id.to_s, id.to_s)
    blob, encrypted_bytes = @azure.get_blob(DEFAULT_CONTAINER, key)
    blob, encrypted_key = @azure.get_blob(DEFAULT_CONTAINER, "#{key}.key")
    blob, encryption_iv = @azure.get_blob(DEFAULT_CONTAINER, "#{key}.iv")
    @encryption.decrypt(encrypted_bytes, encrypted_key, encryption_iv)
  end

  def delete_chunk(parent_id, id)
    key = File.join(parent_id.to_s, id.to_s)
    @azure.delete_blob(DEFAULT_CONTAINER, key)
  rescue Azure::Core::Http::HTTPError => exc
    if exc.status_code == 404
      # ignore
    else
      raise exc
    end
  end

end
