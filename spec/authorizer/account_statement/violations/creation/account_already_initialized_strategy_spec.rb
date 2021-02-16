# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Creation::AccountAlreadyInitializedStrategy do
  subject { described_class.new }

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('account-already-initialized') }
  end

  describe '#violation?' do
    let(:operation) { nil }
    let(:active_card) { true }
    let(:available_limit) { 1 }

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

    it 'allows an account creation when its the first operation' do
      expect(
        subject.violation?(operation: operation, statements_history: [])
      ).to be false
    end

    context 'no account created' do
      let(:not_initialized_rule_name) do
        Authorizer::AccountStatement::Violations::Transaction::
                                      AccountNotInitializedStrategy.new.rule_name
      end

      let(:violations) { [not_initialized_rule_name] }

      it 'allows an account creation when last transaction was unsuccessful' do
        expect(
          subject.violation?(operation: operation, statements_history: statements_history)
        ).to be false
      end
    end

    it 'violates when trying to recreate/update the account' do
      expect(
        subject.violation?(operation: operation, statements_history: statements_history)
      ).to be true
    end

    context 'violations unrelated to account creation' do
      let(:violations) { %w[some-other-violation yet-another-violation] }

      it 'violates when trying to recreate/update the account' do
        expect(
          subject.violation?(operation: operation, statements_history: statements_history)
        ).to be true
      end
    end
  end
end
