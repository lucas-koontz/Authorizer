# frozen_string_literal: true

RSpec.describe Authorizer::Operator do
  let(:operator_input) do
    '{"account": {"active-card": true, "available-limit": 100}}'
  end

  let(:operator_output) do
    [{ account: { "active-card": true, "available-limit": 100 }, violations: [] }]
  end

  describe '#call' do
    let(:processor) { double(call: operator_output) }

    it 'reads data from stdin' do
      expect(ARGF).to receive(:read).and_return(operator_input)
      expect(Authorizer::Processor).to receive(:new).and_return(processor)

      described_class.call
    end

    it 'transforms input into array' do
      expected_input = operator_input.split(/\n/)

      expect(ARGF).to receive(:read).and_return(operator_input)
      expect(Authorizer::Processor).to receive(:call)
        .with(event_stream: expected_input)
        .and_return(operator_output)

      described_class.call
    end

    it 'outputs results from processor into stdout' do
      expected_output = "#{operator_output.join("\n")}\n"

      expect(ARGF).to receive(:read).and_return(operator_input)
      expect(Authorizer::Processor).to receive(:new).and_return(processor)

      expect { described_class.call }.to output(expected_output).to_stdout
    end
  end
end
