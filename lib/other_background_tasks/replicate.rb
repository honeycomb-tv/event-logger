class OtherBackgroundTasks::Replicate

  @queue = "replicate"

  def self.perform(h_file_id)
    h_file = HFile.find(h_file_id)
    Rails.logger.info "Replicating file #{h_file_id} to backup storage..."
    h_file.begin_replicating
    h_file.h_file_chunks.each do |chunk|
      chunk.replicate
    end
    Rails.logger.info "Done."
    h_file.finished_replicating
  end

end