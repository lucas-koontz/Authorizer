# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Transaction::AccountNotInitializedStrategy do
  subject { described_class.new }

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('account-not-initialized') }
  end

  describe '#violation?' do
    let(:event) { nil }
    let(:active_card) { true }
    let(:available_limit) { 100 }

    it 'allows transaction if the account is created' do
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
      ).to be false
    end

    it 'violates when trying to do transaction with account created' do
      expect(
        subject.violation?(event: event, statements_history: [])
      ).to be true

      not_initialized_rule_name = subject.rule_name

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
      ).to be true
    end
  end
end
