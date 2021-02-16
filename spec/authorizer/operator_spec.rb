# frozen_string_literal: true

RSpec.describe Authorizer::Operator do
  describe '#call' do
    let(:operator_input) do
      '{"account": {"active-card": true, "available-limit": 100}}'
    end

    let(:processor_output) { ['output'] }

    let(:processor) { double(call: processor_output) }

    let(:parsed_input) { [{ 'account' => { 'active-card' => true, 'available-limit' => 100 } }] }

    before do
      allow(Authorizer::Processor).to receive(:new).and_return(processor)
    end

    it 'reads data from stdin' do
      expect(ARGF).to receive(:read).and_return(operator_input)

      described_class.call
    end

    it 'parses text input' do
      expect(ARGF).to receive(:read).and_return(operator_input)
      expect(Authorizer::Processor).to receive(:call)
        .with(operation_stream: parsed_input)
        .and_return(processor_output)

      described_class.call
    end

    it 'outputs results from processor into stdout' do
      allow(ARGF).to receive(:read).and_return(operator_input)

      expect { described_class.call }.to output(/output/).to_stdout
    end
  end
end
