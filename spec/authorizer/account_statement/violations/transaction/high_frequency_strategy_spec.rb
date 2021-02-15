# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Transaction::HighFrequencyStrategy do
  subject { described_class.new }

  let(:operation) { { time: '2019-02-13T10:00:00.000Z' } }
  let(:active_card) { true }
  let(:available_limit) { 100 }
  let(:violations) { [] }

  let(:transaction) do
    Authorizer::AccountStatement::TransactionStatement.new(
      active_card: active_card,
      available_limit: available_limit,
      operation: operation,
      violations: violations
    )
  end

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('high-frequency-small-interval') }
  end

  describe '#violation?' do
    it 'allows up to 3 transactions in a 2 minute interval' do
      expect(
        subject.violation?(
          operation: operation,
          statements_history: []
        )
      ).to be false

      expect(
        subject.violation?(
          operation: operation,
          statements_history: [transaction]
        )
      ).to be false

      expect(
        subject.violation?(
          operation: operation,
          statements_history: [transaction, transaction]
        )
      ).to be false

      expect(
        subject.violation?(
          operation: { time: '2019-02-13T10:02:01.000Z' },
          statements_history: [transaction, transaction, transaction]
        )
      ).to be false
    end

    it 'violates when trying a fourth transaction in a 2 minute interval' do
      expect(
        subject.violation?(
          operation: operation,
          statements_history: [transaction, transaction, transaction]
        )
      ).to be true
    end
  end
end
