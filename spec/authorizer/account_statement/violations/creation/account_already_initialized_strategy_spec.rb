# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Creation::AccountAlreadyInitializedStrategy do
  subject { described_class.new }

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('account-already-initialized') }
  end

  describe '#violation?' do
    let(:event) { nil }
    let(:active_card) { true }
    let(:available_limit) { 1 }

    it 'allows an account creation when its the first event' do
      expect(
        subject.violation?(event: event, statements_history: [])
      ).to be false
    end

    it 'allows an account creation when no account has been created' do
      not_initialized_rule_name = Authorizer::AccountStatement::
                                  Violations::Transaction::
                                  AccountNotInitializedStrategy.new.rule_name

      statements_history = [
        Authorizer::AccountStatement::CreationStatement.new(
          active_card: active_card,
          available_limit: available_limit,
          event: event,
          violations: [not_initialized_rule_name]
        )
      ]

      expect(
        subject.violation?(event: event, statements_history: statements_history)
      ).to be false
    end

    it 'violates when trying to recreate/update the account' do
      statements_history = [
        Authorizer::AccountStatement::CreationStatement.new(
          active_card: active_card,
          available_limit: available_limit,
          event: event,
          violations: []
        )
      ]

      expect(
        subject.violation?(event: event, statements_history: statements_history)
      ).to be true

      statements_history = [
        Authorizer::AccountStatement::CreationStatement.new(
          active_card: active_card,
          available_limit: available_limit,
          event: event,
          violations: %w[some-other-violation yet-another-violation]
        )
      ]

      expect(
        subject.violation?(event: event, statements_history: statements_history)
      ).to be true
    end
  end
end
