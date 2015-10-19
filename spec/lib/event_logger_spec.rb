# Produce consistent, self describing log entries which allow us
# to measure things across the whole system

# Starting in the Rails world but there is no reason why this should not be
# factored out of honeycomb-web and also used by Ingest and the Receiving Agent

require 'rails_helper'

EVENTS = {
  transcode_start: 20000,
  transcode_end: 20001,
  transcode_queue: 20002,
  transcode_abort: 20003
}

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

  it 'passes the log entry to the rails logger so it ends up in the right place' do
    expect(Rails.logger).to receive(:info).with('type=job name=make_thumbnails state=failed').once

    subject.log(:job, name: 'make_thumbnails', state: 'failed')
  end

  it 'adds a traceable job_id to every logged event' do
    skip 'not yet implemented'
  end

  it 'determines the severity from the event mapping' do
    skip 'not yet implemented'

    expect(Rails.logger).to receive(:error).with('type=job name=validate state=failed').once

    subject.log(:job, name: 'validate', state: :failed)
  end

  it 'allows overriding of severity' do
    skip 'not yet implemented'

    expect(Rails.logger).to receive(:warn).with('type=mark name=all_jobs_scheduled').once

    subject.log(:mark, name: 'all_jobs_scheduled', severity: :warn)
  end
end
