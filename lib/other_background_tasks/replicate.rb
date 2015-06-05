class OtherBackgroundTasks::Replicate

  @queue = "replicate"

  def self.perform(h_file_id)
    h_file = HFile.find_by_id(h_file_id)
    return if h_file.nil? # File may have been deleted in the meantime

    Rails.logger.info "Replicating HFile #{h_file_id} to backup storage..."
    h_file.begin_replicating
    h_file.h_file_chunks.each do |chunk|
      chunk.replicate
    end
    Rails.logger.info "Done."
    h_file.finished_replicating
  rescue Exception => exc
    Rails.logger.error "Error replicating HFile #{h_file_id}: #{exc.message}"
    Airbrake.notify(exc)
  end

end