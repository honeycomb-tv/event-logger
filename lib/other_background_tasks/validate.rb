class OtherBackgroundTasks::Validate

  @queue = "validate"

  def self.perform(h_file_id)
    h_file = HFile.find(h_file_id)
    Rails.logger.info "Validating HFile #{h_file_id}..."
    h_file.begin_validating
    if h_file.valid_sha3?
      Rails.logger.info "Done."
      h_file.pass_validation
    else
      h_file.fail_validation
      Rails.logger.info "Failed validation due to mismatched sha3"
    end
  rescue Exception => exc
    h_file.fail_validation
    Rails.logger.error "Exception during validation: #{exc.message}"
    Airbrake.notify(exc)
  end

end