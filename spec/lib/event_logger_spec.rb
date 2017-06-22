# Produce consistent, self describing log entries which allow us
# to measure things across the whole system

require_relative '../../lib/event_logger.rb'

describe EventLogger do
  subject { described_class.instance }

  let(:output) { instance_double(EventLogger::Output::IO) }

  before { allow(subject.config).to receive(:logger_instance).and_return(output) }

  it 'is a singleton' do
    expect(subject).to eq(described_class.instance)
  end

  it 'outputs the log entry' do
    allow(output).to receive(:write)
    subject.log(:job, name: 'make_thumbnails', state: 'failed')
    expect(output)
      .to have_received(:write)
      .with(:info, type: :job, name: 'make_thumbnails', state: 'failed').once
  end

  it 'determines the severity from the event mapping' do
    allow(output).to receive(:write)
    subject.mapping = { 'validate' => { state: :failed,
                                        severity: :error } }
    subject.log(:job, name: 'validate', state: :failed)
    expect(output)
      .to have_received(:write)
      .with(:error, type: :job, name: 'validate', state: :failed).once
  end

  it 'allows overriding of severity' do
    allow(output).to receive(:write)
    subject.log(:mark, name: 'all_jobs_scheduled', severity: :warn)
    expect(output)
      .to have_received(:write)
      .with(:warn, type: :mark, name: 'all_jobs_scheduled').once
  end

  it 'can create a Correlation ID' do
    first_correlation_id = subject.create_correlation_id
    expect(first_correlation_id)
      .to match('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')

    second_correlation_id = subject.create_correlation_id
    expect(second_correlation_id)
      .to match('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')

    expect(first_correlation_id).not_to eq(second_correlation_id)
  end
end
