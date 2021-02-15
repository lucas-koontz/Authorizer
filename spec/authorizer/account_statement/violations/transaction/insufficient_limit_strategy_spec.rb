# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Transaction::InsufficientLimitStrategy do
  subject { described_class.new }

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('insufficient-limit') }
  end

  describe '#violation?' do
    let(:event) { { amount: 50 } }
    let(:active_card) { true }

    it 'allows transaction if balance is sufficient' do
      available_limit = 100

      statements_history = [
        Authorizer::AccountStatement::TransactionStatement.new(
          active_card: active_card,
          available_limit: available_limit,
          event: event,
          violations: []
        )
      ]

      expect(
        subject.violation?(event: event, statements_history: statements_history)
      ).to be false

      available_limit = 50

      statements_history = [
        Authorizer::AccountStatement::TransactionStatement.new(
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

    it 'violates when trying to do a transaction with amount higher than available limit' do
      available_limit = 10

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
    end
  end
end
