# frozen_string_literal: true

# # frozen_string_literal: true

RSpec.describe Authorizer::Processor do
  describe '#call' do
    context 'base statements' do
      let(:operation) { { operation: 'operation_type' } }

      let(:statement) do
        Authorizer::AccountStatement::BaseStatement.new(
          active_card: nil,
          available_limit: nil,
          operation: operation
        )
      end

      before do
        allow(Authorizer::AccountStatement::Builder).to receive(:call)
          .and_return(statement)
      end

      it 'turns each operation into statement' do
        operation_stream = [operation]
        expect(
          described_class.call(
            operation_stream: operation_stream
          ).count
        ).to eq operation_stream.count

        operation_stream = [operation, operation, operation, operation]
        expect(
          described_class.call(
            operation_stream: operation_stream
          ).count
        ).to eq operation_stream.count
      end

      it 'returns an array of statements' do
        operation_stream = [operation, operation, operation]
        expect(
          described_class.call(
            operation_stream: operation_stream
          )
        ).to be_an_instance_of(Array)

        expect(
          described_class.call(
            operation_stream: operation_stream
          )
        ).to all(be_an_instance_of(Authorizer::AccountStatement::BaseStatement))
      end
    end
  end
end
