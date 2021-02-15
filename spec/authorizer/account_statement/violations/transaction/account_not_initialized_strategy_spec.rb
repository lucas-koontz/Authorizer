# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Transaction::AccountNotInitializedStrategy do
  subject { described_class.new }

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('account-not-initialized') }
  end

  describe '#violation?' do
    let(:operation) { nil }
    let(:active_card) { true }
    let(:available_limit) { 100 }

    let(:violations) { [] }

    let(:statements_history) do
      [
        Authorizer::AccountStatement::CreationStatement.new(
          active_card: active_card,
          available_limit: available_limit,
          operation: operation,
          violations: violations
        )
      ]
    end

    it 'allows transaction if the account is created' do
      expect(
        subject.violation?(operation: operation, statements_history: statements_history)
      ).to be false
    end

    context 'violations' do
      let(:violations) { [subject.rule_name] }

      it 'violates when trying to do transaction with account created' do
        expect(
          subject.violation?(operation: operation, statements_history: [])
        ).to be true

        expect(
          subject.violation?(operation: operation, statements_history: statements_history)
        ).to be true
      end
    end
  end
end
