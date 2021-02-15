# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Adapters::TransactionStatementAdapter do
  let(:time) { '2019-02-13T11:00:00.000Z' }
  let(:merchant) { 'Amazon' }
  let(:amount) { 10 }
  let(:operation) { { time: time, merchant: merchant, amount: amount } }
  let(:active_card) { true }
  let(:available_limit) { 1000 }
  let(:violations) { [] }

  def transaction(oprt = operation)
    Authorizer::AccountStatement::TransactionStatement.new(
      active_card: active_card,
      available_limit: available_limit,
      operation: oprt,
      violations: violations
    )
  end

  let(:statements_history) do
    [
      transaction
    ]
  end

  let(:raw_operation_merchant) { 'Burguer King' }
  let(:raw_operation_amount) { 20 }
  let(:raw_operation_time) { '2019-02-13T11:00:00.000Z' }

  let(:raw_operation) do
    { transaction: { merchant: raw_operation_merchant, amount: raw_operation_amount, time: raw_operation_time } }
  end

  subject { described_class.new(raw_operation: raw_operation, statements_history: statements_history) }

  describe '#build' do
    it 'can build an transaction statement' do
      expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::TransactionStatement)
      expect(subject.build.active_card).to eq(active_card)
      expect(subject.build.available_limit).to eq(available_limit - raw_operation_amount)
      expect(subject.build.violations).to be_empty
    end

    context 'account has not been created' do
      let(:statements_history) { [] }

      let(:rule_name) do
        Authorizer::AccountStatement::Violations::Transaction::AccountNotInitializedStrategy.new.rule_name
      end

      it 'builds a new statement with a violation' do
        expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::TransactionStatement)
        expect(subject.build.active_card).to eq(false)
        expect(subject.build.available_limit).to eq(0)
        expect(subject.build.violations).not_to be_empty
        expect(subject.build.violations).to include(rule_name)
      end

      context 'attempting to do transaction without account more than once' do
        let(:violations) { [rule_name] }
        it 'builds a new statement with a violation' do
          expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::TransactionStatement)
          expect(subject.build.active_card).to eq(false)
          expect(subject.build.available_limit).to eq(0)
          expect(subject.build.violations).not_to be_empty
          expect(subject.build.violations).to include(rule_name)
        end
      end
    end

    context 'card not active' do
      let(:active_card) { false }

      let(:rule_name) do
        Authorizer::AccountStatement::Violations::Transaction::CardNotActiveStrategy.new.rule_name
      end

      it 'builds a new statement with a violation' do
        expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::TransactionStatement)
        expect(subject.build.active_card).to eq(active_card)
        expect(subject.build.available_limit).to eq(available_limit)
        expect(subject.build.violations).not_to be_empty
        expect(subject.build.violations).to include(rule_name)
      end
    end

    context 'insufficient limit' do
      let(:raw_operation_amount) { available_limit + 1 }

      let(:rule_name) do
        Authorizer::AccountStatement::Violations::Transaction::InsufficientLimitStrategy.new.rule_name
      end

      it 'builds a new statement with a violation' do
        expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::TransactionStatement)
        expect(subject.build.active_card).to eq(active_card)
        expect(subject.build.available_limit).to eq(available_limit)
        expect(subject.build.violations).not_to be_empty
        expect(subject.build.violations).to include(rule_name)
      end
    end

    context 'high frequency transactions' do
      let(:statements_history) do
        [
          transaction({ time: '2019-02-13T11:00:00.000Z', merchant: 'Habbib\'s', amount: 30 }),
          transaction({ time: '2019-02-13T11:00:30.000Z', merchant: 'Taco Bell', amount: 50 }),
          transaction({ time: '2019-02-13T11:01:59.000Z', merchant: 'Taco Bell', amount: 50 })
        ]
      end

      let(:raw_operation_time) { '2019-02-13T11:02:00.000Z' }

      let(:rule_name) do
        Authorizer::AccountStatement::Violations::Transaction::HighFrequencyStrategy.new.rule_name
      end

      it 'builds a new statement with a violation' do
        expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::TransactionStatement)
        expect(subject.build.active_card).to eq(active_card)
        expect(subject.build.available_limit).to eq(available_limit)
        expect(subject.build.violations).not_to be_empty
        expect(subject.build.violations).to include(rule_name)
      end
    end

    context 'double transaction transactions' do
      let(:time) { '2019-02-13T11:00:00.000Z' }
      let(:raw_operation_time) { '2019-02-13T11:02:00.000Z' }

      let(:raw_operation_merchant) { merchant }
      let(:raw_operation_amount) { amount }

      let(:rule_name) do
        Authorizer::AccountStatement::Violations::Transaction::DoubleTransactionStrategy.new.rule_name
      end

      it 'builds a new statement with a violation' do
        expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::TransactionStatement)
        expect(subject.build.active_card).to eq(active_card)
        expect(subject.build.available_limit).to eq(available_limit)
        expect(subject.build.violations).not_to be_empty
        expect(subject.build.violations).to include(rule_name)
      end
    end

    context 'insuficient limit and high frequency transactions' do
      let(:statements_history) do
        [
          transaction({ time: '2019-02-13T11:00:00.000Z', merchant: 'Habbib\'s', amount: 30 }),
          transaction({ time: '2019-02-13T11:00:30.000Z', merchant: 'Taco Bell', amount: 50 }),
          transaction({ time: '2019-02-13T11:01:59.000Z', merchant: 'Taco Bell', amount: 50 })
        ]
      end

      let(:raw_operation_time) { '2019-02-13T11:02:00.000Z' }

      let(:raw_operation_amount) { available_limit + 1 }

      it 'builds a new statement with a violation' do
        expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::TransactionStatement)
        expect(subject.build.active_card).to eq(active_card)
        expect(subject.build.available_limit).to eq(available_limit)
        expect(subject.build.violations).not_to be_empty
        expect(subject.build.violations).to include(
          Authorizer::AccountStatement::Violations::Transaction::HighFrequencyStrategy.new.rule_name,
          Authorizer::AccountStatement::Violations::Transaction::InsufficientLimitStrategy.new.rule_name
        )
      end
    end

    context 'insuficient limit and  double transaction transactions' do
      let(:time) { '2019-02-13T11:00:00.000Z' }
      let(:raw_operation_time) { '2019-02-13T11:02:00.000Z' }

      let(:amount) { 10 }

      let(:raw_operation_merchant) { merchant }
      let(:raw_operation_amount) { amount }

      let(:available_limit) { 0 }

      it 'builds a new statement with a violation' do
        expect(subject.build).to be_an_instance_of(Authorizer::AccountStatement::TransactionStatement)
        expect(subject.build.active_card).to eq(active_card)
        expect(subject.build.available_limit).to eq(available_limit)
        expect(subject.build.violations).not_to be_empty
        expect(subject.build.violations).to include(
          Authorizer::AccountStatement::Violations::Transaction::DoubleTransactionStrategy.new.rule_name,
          Authorizer::AccountStatement::Violations::Transaction::InsufficientLimitStrategy.new.rule_name
        )
      end
    end
  end
end
