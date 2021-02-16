# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::BaseStatement do
  let(:active_card) { true }
  let(:available_limit) { 100 }
  let(:operation) { 'operation' }
  let(:violations) { ['a-very-bad-violation'] }

  subject do
    described_class.new(
      active_card: active_card,
      available_limit: available_limit,
      operation: operation,
      violations: violations
    )
  end

  describe '#new' do
    it { expect(subject.active_card).to eq(active_card) }
    it { expect(subject.available_limit).to eq(available_limit) }
    it { expect(subject.violations).to eq(violations) }
  end

  describe '#print' do
    it 'prints a valid statement' do
      expect(subject.print).to eq(
        '{"account":{"active-card":true,"available-limit":100,"violations":["a-very-bad-violation"]}}'
      )
    end
  end
end
