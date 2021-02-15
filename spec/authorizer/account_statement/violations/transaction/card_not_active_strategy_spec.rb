# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::
               Transaction::CardNotActiveStrategy do
  subject { described_class.new }

  describe '#rule_name' do
    it { expect(subject.rule_name).to eq('card-not-active') }
  end

  describe '#violation?' do
    let(:event) { nil }
    let(:active_card) { true }
    let(:available_limit) { 1 }

    it 'allows transaction if the card is active' do
      active_card = true

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

    it 'violates when trying to do transaction with card deactivated' do
      active_card = false

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
