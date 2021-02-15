# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Builder do
  describe '#call' do
    let(:raw_operation) { { transaction: { merchant: 'merchant', amount: 'amount', time: 'time' } } }

    let(:statements_history) { ['not_empty'] }

    let(:build) { 'build' }

    let(:adapter) do
      double(
        adapter: double(
          new: double(
            build: build
          )
        )
      )
    end

    it 'builds an statement from an adapter' do
      expect(Authorizer::AccountStatement::BuilderAdapterDelegator).to receive(:new)
        .with(raw_operation)
        .and_return(adapter)

      expect(
        described_class.call(raw_operation: raw_operation, statements_history: statements_history)
      ).to eq(build)
    end
  end
end
