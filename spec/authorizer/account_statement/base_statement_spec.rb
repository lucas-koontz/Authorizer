# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::BaseStatement do
  let(:active_card) { true }
  let(:available_limit) { 100 }
  let(:event) { 'event' }
  let(:violations) { ['a-very-bad-violation'] }

  subject do
    described_class.new(
      active_card: active_card,
      available_limit: available_limit,
      event: event,
      violations: violations
    )
  end

  describe '#new' do
    it { expect(subject.active_card).to eq(active_card) }
    it { expect(subject.available_limit).to eq(available_limit) }
    it { expect(subject.violations).to eq(violations) }
  end

  describe '#to_s' do
    it 'outpus a valid statement' do
      expect(subject.to_s).to eq(
        { account: { 'active-card': active_card, 'available-limit': available_limit,
                     violations: violations } }
      )
    end
  end
end
