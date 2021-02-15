# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Transaction::CardNotActiveStrategy do
  subject { described_class.new }

  let(:operation) { nil }
  let(:active_card) { true }
  let(:available_limit) { 1 }

  let(:violations) { [] }

  let(:statements_history) do
    [
      Authorizer::AccountStatement::TransactionStatement.new(
        active_card: active_card,
        available_limit: available_limit,
        operation: operation,
        violations: violations
      )
    ]
  end

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('card-not-active') }
  end

  describe '#violation?' do
    it 'allows transaction if the card is active' do
      expect(
        subject.violation?(operation: operation, statements_history: statements_history)
      ).to be false
    end

    context 'card is not active' do
      let(:active_card) { false }

      it 'violates when trying to do transaction' do
        expect(
          subject.violation?(operation: operation, statements_history: statements_history)
        ).to be true
      end
    end
  end
end
