require_relative '../../../lib/event_logger/config'

describe EventLogger::Config do
  subject { described_class.new }

  describe '#logger' do
    it 'defaults to :logger' do
      expect(subject.logger).to eq(:logger)
    end

    context 'with EVENT_LOGGER_LOGGER env' do
      let(:env_logger) { 'stdout' }

      before { ENV['EVENT_LOGGER_LOGGER'] = env_logger }

      after { ENV.delete('EVENT_LOGGER_LOGGER') }

      it 'defaults to EVENT_LOGGER_LOGGER' do
        expect(subject.logger).to eq(:stdout)
      end
    end
  end

  describe '#logger=' do
    it 'sets logger to supported type' do
      subject.logger = :stdout
      expect(subject.logger).to eq(:stdout)
    end

    it 'raises an error if set to unknown symbol' do
      expect { subject.logger = :unknown }.to raise_error(ArgumentError)
    end
  end

  describe '#logger_instance' do
    it 'returns Logger for :logger' do
      subject.logger = :logger
      expect(subject.logger).to eq(:logger)
      expect(subject.logger_instance).to be_a(EventLogger::Output::Logger)
    end

    it 'returns IO(STDOUT) for :stdout' do
      subject.logger = :stdout
      expect(subject.logger).to eq(:stdout)
      expect(subject.logger_instance).to be_a(EventLogger::Output::IO)
      expect(subject.logger_instance.stream).to eq($stdout)
    end

    context 'when writing to a logger object' do
      let(:output) { instance_double(Object) }

      before { allow(output).to receive(:respond_to?).with(:<<).and_return(false).twice }

      it 'will use the Logger method' do
        subject.logger = output
        expect(subject.logger).to eq(output)
        expect(subject.logger_instance).to be_a(EventLogger::Output::Logger)
        expect(subject.logger_instance.logger).to eq(output)
      end
    end

    context 'when writing to an IO object' do
      let(:output) { instance_double(IO) }

      before { allow(output).to receive(:respond_to?).with(:<<).and_return(true).twice }

      it 'will use the IO method' do
        subject.logger = output
        expect(subject.logger).to eq(output)
        expect(subject.logger_instance).to be_a(EventLogger::Output::IO)
        expect(subject.logger_instance.stream).to eq(output)
      end
    end
  end
end
