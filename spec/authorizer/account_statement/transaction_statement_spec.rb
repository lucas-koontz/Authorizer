# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::TransactionStatement do
  let(:active_card) { true }
  let(:available_limit) { 100 }
  let(:violations) { ['a-very-bad-violation'] }

  let(:merchant) { "Habbib\'s" }
  let(:amount) { 10 }
  let(:time) { '2019-02-13T11:00:00.000Z' }
  let(:event) do
    { merchant: merchant, amount: amount, time: time }
  end

  subject do
    described_class.new(
      active_card: active_card,
      available_limit: available_limit,
      event: event,
      violations: violations
    )
  end

  describe '#new' do
    it { expect(subject.merchant).to eq(merchant) }
    it { expect(subject.time).to eq(DateTime.parse(time)) }
  end
end
