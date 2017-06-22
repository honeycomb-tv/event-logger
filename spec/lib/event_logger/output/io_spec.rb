require_relative '../../../../lib/event_logger/output/io'

describe EventLogger::Output::IO do
  subject { described_class.new(buffer) }

  let(:buffer) { StringIO.new }

  describe '#write' do
    it 'outputs JSON with severity and generated_at' do
      allow(Time).to receive(:now).and_return(Time.new(2017))
      subject.write(:warn, type: :process, foo: 'bar')
      expect(buffer.string)
        .to eq(%({"generated_at":1483228800000,"severity":"warn","type":"process","foo":"bar"}\n))
    end
  end
end
