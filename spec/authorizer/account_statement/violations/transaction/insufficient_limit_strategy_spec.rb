# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Transaction::InsufficientLimitStrategy do
  subject { described_class.new }

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('insufficient-limit') }
  end

  describe '#violation?' do
    let(:amount) { 0 }
    let(:operation) { { amount: amount } }
    let(:active_card) { true }
    let(:available_limit) { 100 }
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

    context 'when available limit is sufficient' do
      context 'transaction amount is less than available limit' do
        let(:amount) { available_limit - 1 }
        it 'allows' do
          expect(
            subject.violation?(operation: operation, statements_history: statements_history)
          ).to be false
        end
      end

      context 'transaction amount is less than available limit' do
        let(:amount) { available_limit }
        it 'allows' do
          expect(
            subject.violation?(operation: operation, statements_history: statements_history)
          ).to be false
        end
      end
    end

    context 'when available limit is insufficient' do
      let(:amount) { available_limit + 1 }
      it 'violates' do
        expect(
          subject.violation?(operation: operation, statements_history: statements_history)
        ).to be true
      end
    end
  end
end
