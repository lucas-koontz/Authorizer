# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      class Context
        attr_accessor :strategy
        attr_reader :operation, :statements_history

        def initialize(operation:, statements_history:, strategy: nil)
          @operation = operation
          @statements_history = statements_history
          @strategy = strategy
        end

        def verify
          return strategy.rule_name if strategy.violation?(operation: operation,
                                                           statements_history: statements_history)

          nil
        end
      end
    end
  end
end
