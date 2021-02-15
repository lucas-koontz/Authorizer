# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::CreationStatement do
  let(:active_card) { true }
  let(:available_limit) { 100 }
  let(:violations) { ['a-very-bad-violation'] }
  let(:event) { nil }

  describe '#new' do
    it {
      expect(described_class.new(
               active_card: active_card,
               available_limit: available_limit,
               event: event,
               violations: violations
             )).to be_truthy
    }
  end
end
