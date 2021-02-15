# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Adapters
      class TransactionStatementAdapter < BaseAdapter
        def build
          if violations.empty? # can create
            build_instance(
              active_card: lastest_statement.active_card,
              available_limit: lastest_statement.available_limit - operation[:amount]
            )
          elsif statements_history.empty?
            build_instance(
              active_card: false,
              available_limit: 0
            )
          else
            build_instance_with_violations
          end
        end

        private

        def klass
          TransactionStatement
        end

        def operation_id
          :transaction
        end

        def violation_strategies
          [
            Violations::Transaction::AccountNotInitializedStrategy.new,
            Violations::Transaction::CardNotActiveStrategy.new,
            Violations::Transaction::InsufficientLimitStrategy.new,
            Violations::Transaction::HighFrequencyStrategy.new,
            Violations::Transaction::DoubleTransactionStrategy.new
          ]
        end
      end
    end
  end
end
