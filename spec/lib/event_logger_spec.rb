# Produce consistent, self describing log entries which allow us
# to measure things across the whole system

require 'event_logger'

describe EventLogger do

  subject { EventLogger.instance }

  it 'is a singleton' do
    expect(subject).to eq(EventLogger.instance)
  end

  it 'exposes a class method .log for convenience' do
    expect(subject).to receive(:log).with(:job, name: 'validate', state: :completed)

    EventLogger.log(:job, name: 'validate', state: :completed)
  end

  it 'formats all passed details into readable key value pairs' do
    entry = subject.send :format_log_entry, { type: :job, name: 'transcoding_job', state: :enqueued, materialid: 'TTB/GODD004/030' }

    expect(entry).to eq('type=job name=transcoding_job state=enqueued materialid=TTB/GODD004/030')
  end

  it 'can be configured with a logger of your choice' do

  end

  it 'passes the log entry to the logger so it ends up in the right place' do
    my_logger = instance_double(Logger)
    subject.logger = my_logger
    expect(my_logger).to receive(:info).with('type=job name=make_thumbnails state=failed').once

    subject.log(:job, name: 'make_thumbnails', state: 'failed')
  end

  it 'determines the severity from the event mapping' do

    my_logger = instance_double(Logger)
    subject.logger = my_logger
    subject.mapping = {"validate" => {state: :failed, severity: :error}}
    expect(my_logger).to receive(:error).with('type=job name=validate state=failed').once

    subject.log(:job, name: 'validate', state: :failed)
  end

  it 'allows overriding of severity' do

    my_logger = instance_double(Logger)
    subject.logger = my_logger
    expect(my_logger).to receive(:warn).with('type=mark name=all_jobs_scheduled').once

    subject.log(:mark, name: 'all_jobs_scheduled', severity: :warn)
  end
end
