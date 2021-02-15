# frozen_string_literal: true

RSpec.describe Authorizer::AccountStatement::Violations::Context do
  let(:concrete_strategy_a) do
    Class.new do
      def rule_name
        'strategy-a'
      end

      def violation?(**)
        true
      end
    end
  end

  let(:concrete_strategy_b) do
    Class.new do
      def rule_name
        'strategy-b'
      end

      def violation?(**)
        false
      end
    end
  end

  let(:strategyA) { concrete_strategy_a.new }
  let(:strategyB) { concrete_strategy_b.new }

  let(:event) { { event: 'event' } }
  let(:statements_history) { [] }

  describe '#violation?' do
    it 'access a strategy violations?' do
      expect_any_instance_of(concrete_strategy_a).to receive(:violation?)
        .with(event: event, statements_history: statements_history)
        .and_call_original

      context = described_class.new(
        event: event,
        statements_history: statements_history,
        strategy: strategyA
      )

      context.violation?
    end

    it 'can have strategy changed' do
      context = described_class.new(
        event: event,
        statements_history: statements_history,
        strategy: strategyA
      )

      context.strategy = strategyB

      expect(context.strategy).to be_an_instance_of(concrete_strategy_b)
    end

    it 'returns strategy rule name if a violation occurs' do
      context = described_class.new(
        event: event,
        statements_history: statements_history,
        strategy: strategyA
      )

      expect(context.violation?).to eq(strategyA.rule_name)
    end

    it 'returns nil if no violation is found' do
      context = described_class.new(
        event: event,
        statements_history: statements_history,
        strategy: strategyB
      )

      expect(context.violation?).to eq(nil)
    end
  end
end
