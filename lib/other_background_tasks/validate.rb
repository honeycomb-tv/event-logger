class OtherBackgroundTasks::Validate

  @queue = "validate"

  def self.perform(h_file_id)
    h_file = HFile.find_by_id(h_file_id)
    return if h_file.nil? # File may have been deleted in the meantime

    Rails.logger.info "Validating HFile #{h_file_id}..."
    h_file.begin_validating
    if h_file.valid_sha3?
      Rails.logger.info "Done."
      h_file.pass_validation
    else
      h_file.fail_validation
      Rails.logger.warn "Failed validation due to mismatched sha3"
    end
  rescue Exception => exc
    h_file.fail_validation unless h_file.nil?
    Rails.logger.error "Error validating HFile #{h_file_id}: #{exc.message}"
    Airbrake.notify(exc)
  end

end