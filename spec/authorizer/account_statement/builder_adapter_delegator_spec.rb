# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::BuilderAdapterDelegator do
  let(:creation_operation) do
    { account: { "active-card": true, "available-limit": 100 } }
  end

  let(:transaction_operation) do
    { transaction: { merchant: 'Burger King', amount: 20, time: '2019-02-13T10:00:00.000Z' } }
  end

  describe '#adapter' do
    it 'can delegate to CreationStatement adapter' do
      expect(
        described_class.new(creation_operation).adapter
      ).to eq Authorizer::AccountStatement::Adapters::CreationStatementAdapter
    end

    it 'can delegate to TransactionStatement adapter' do
      expect(
        described_class.new(transaction_operation).adapter
      ).to eq Authorizer::AccountStatement::Adapters::TransactionStatementAdapter
    end
  end
end
