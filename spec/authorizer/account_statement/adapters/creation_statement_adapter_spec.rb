# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Adapters::CreationStatementAdapter do
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

  let(:raw_operation_active_card) { active_card }
  let(:raw_operation_available_limit) { available_limit }

  let(:raw_operation) do
    { account: { "active-card": raw_operation_active_card, "available-limit": raw_operation_available_limit } }
  end

  subject { described_class.new(raw_operation: raw_operation, statements_history: statements_history) }

  describe '#build' do
    context 'first operation' do
      let(:statements_history) { [] }

      it 'can build an creation statement' do
        expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::CreationStatement)
        expect(subject.build.active_card).to eq(raw_operation_active_card)
        expect(subject.build.available_limit).to eq(raw_operation_available_limit)
        expect(subject.build.violations).to be_empty
      end
    end

    context 'account has been created' do
      let(:raw_operation_active_card) { !active_card }
      let(:raw_operation_available_limit) { available_limit - 1 }

      let(:rule_name) do
        Authorizer::AccountStatement::Violations::Creation::AccountAlreadyInitializedStrategy.new.rule_name
      end

      it 'uses last statement and build a new one with a violation' do
        expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::CreationStatement)
        expect(subject.build.active_card).to eq(active_card)
        expect(subject.build.available_limit).to eq(available_limit)
        expect(subject.build.violations).not_to be_empty
        expect(subject.build.violations).to include(rule_name)
      end
    end
  end
end
