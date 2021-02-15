# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Transaction::DoubleTransactionStrategy do
  subject { described_class.new }

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('double-transaction') }
  end

  describe '#violation?' do
    let(:merchant) { 'Amazon1' }
    let(:amount) { 10 }

    let(:operation) { { time: '2019-02-13T10:00:00.000Z', merchant: merchant, amount: amount } }
    let(:active_card) { true }
    let(:available_limit) { 100 }

    let(:transaction) do
      Authorizer::AccountStatement::TransactionStatement.new(
        active_card: active_card,
        available_limit: available_limit,
        operation: operation,
        violations: []
      )
    end

    it 'allows transactions to same merchant with different amount in a 2 minutes interval' do
      expect(
        subject.violation?(
          operation: { time: '2019-02-13T10:00:00.000Z', merchant: merchant, amount: amount + 1 },
          statements_history: [transaction]
        )
      ).to be false

      expect(
        subject.violation?(
          operation: { time: '2019-02-13T10:02:00.000Z', merchant: merchant, amount: amount + 1 },
          statements_history: [transaction]
        )
      ).to be false
    end

    it 'allows transactions to same merchant with same amount in an interval higher than 2 minutes' do
      expect(
        subject.violation?(
          operation: { time: '2019-02-13T10:02:01.000Z', merchant: merchant, amount: amount },
          statements_history: [transaction]
        )
      ).to be false
    end

    it 'violates when trying to do similar transactions in a 2 minutes interval' do
      expect(
        subject.violation?(
          operation: { time: '2019-02-13T10:00:00.000Z', merchant: merchant, amount: amount },
          statements_history: [transaction]
        )
      ).to be true

      expect(
        subject.violation?(
          operation: { time: '2019-02-13T10:02:00.000Z', merchant: merchant, amount: amount },
          statements_history: [transaction]
        )
      ).to be true
    end
  end
end
