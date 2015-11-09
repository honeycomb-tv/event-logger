class LegacyStorage::ChunkNotFoundException < Exception

  def initialize
    super("The specified chunk could not be found")
  end

end
