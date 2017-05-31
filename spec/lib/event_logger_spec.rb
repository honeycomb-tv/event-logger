# Produce consistent, self describing log entries which allow us
# to measure things across the whole system

require_relative '../../lib/event_logger.rb'

describe EventLogger do
  subject { described_class.instance }

  it 'is a singleton' do
    expect(subject).to eq(described_class.instance)
  end

  it 'formats all passed details into JSON' do
    entry = subject.send :format_log_entry, type: :job,
                                            name: 'transcoding_job',
                                            state: :enqueued,
                                            materialid: 'TTB/GODD004/030'

    expect(entry)
      .to eq('{"type":"job","name":"transcoding_job",'\
             '"state":"enqueued","materialid":"TTB/GODD004/030"}')
  end

  it 'passes the log entry to the logger so it ends up in the right place' do
    my_logger = instance_spy(Logger)
    allow(my_logger).to receive(:info)
    subject.logger = my_logger

    subject.log(:job, name: 'make_thumbnails', state: 'failed')

    expect(my_logger)
      .to have_received(:info)
      .with('{"type":"job","name":"make_thumbnails","state":"failed"}').once
  end

  it 'determines the severity from the event mapping' do
    my_logger = instance_spy(Logger)
    allow(my_logger).to receive(:error)
    subject.logger = my_logger
    subject.mapping = { 'validate' => { state: :failed,
                                        severity: :error } }
    subject.log(:job, name: 'validate', state: :failed)

    expect(my_logger)
      .to have_received(:error)
      .with('{"type":"job","name":"validate","state":"failed"}').once
  end

  it 'allows overriding of severity' do
    my_logger = instance_spy(Logger)
    allow(my_logger).to receive(:warn)
    subject.logger = my_logger

    subject.log(:mark, name: 'all_jobs_scheduled', severity: :warn)

    expect(my_logger)
      .to have_received(:warn)
      .with('{"type":"mark","name":"all_jobs_scheduled"}').once
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
