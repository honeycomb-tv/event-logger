require_relative '../../../../lib/event_logger/output/logger'

describe EventLogger::Output::Logger do
  subject { described_class.new(Logger.new(STDOUT)) }

  describe '#write' do
    it 'calls severity method with JSON' do
      allow(subject.logger).to receive(:warn)
      subject.write(:warn, type: :process, foo: 'bar')
      expect(subject.logger).to have_received(:warn).with('{"type":"process","foo":"bar"}')
    end
  end
end
