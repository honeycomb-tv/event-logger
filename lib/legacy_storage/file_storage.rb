class LegacyStorage::FileStorage
  attr_reader :base_path

  def initialize(opts)
    @base_path = opts[:base_path]
    FileUtils.makedirs(@base_path)
    @encryption = LegacyStorage::Encryption.new(opts[:encryption])
  end

  def store_chunk(parent_id, id, bytes)
    encrypted = @encryption.encrypt(bytes)
    dir_s = File.join(@base_path, parent_id.to_s)
    FileUtils.makedirs(dir_s)
    File.open(File.join(dir_s, id.to_s), 'wb') do |f|
      f.write(encrypted[:bytes])
    end
    File.open(File.join(dir_s, "#{id.to_s}.key"), 'wb') do |f|
      f.write(encrypted[:encrypted_key])
    end
    File.open(File.join(dir_s, "#{id.to_s}.iv"), 'wb') do |f|
      f.write(encrypted[:encryption_iv])
    end
  end

  def retrieve_chunk(parent_id, id)
    dir_s = File.join(@base_path, parent_id.to_s)
    encrypted_bytes, encrypted_key, encryption_iv = nil
    File.open(File.join(dir_s, id.to_s), 'rb') do |f|
      encrypted_bytes = f.read
    end
    File.open(File.join(dir_s, "#{id.to_s}.key"), 'rb') do |f|
      encrypted_key = f.read
    end
    File.open(File.join(dir_s, "#{id.to_s}.iv"), 'rb') do |f|
      encryption_iv = f.read
    end
    @encryption.decrypt(encrypted_bytes, encrypted_key, encryption_iv)
  end

  def delete_chunk(parent_id, id)
    dir_s = File.join(@base_path, parent_id.to_s)
    [File.join(dir_s, id.to_s), File.join(dir_s, "#{id.to_s}.key"), File.join(dir_s, "#{id.to_s}.iv")].each do |filename|
      File.delete(filename) if File.exist?(filename)
    end
    if Dir.glob(File.join(dir_s, "*")).count == 0
      Dir.delete(dir_s) if Dir.exist?(dir_s)
    end
  end
end
