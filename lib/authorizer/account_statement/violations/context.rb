# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      class Context
        attr_accessor :strategy
        attr_reader :event, :statements_history

        def initialize(event:, statements_history:, strategy: nil)
          @event = event
          @statements_history = statements_history
          @strategy = strategy
        end

        def violation?
          return strategy.rule_name if strategy.violation?(event: event,
                                                           statements_history: statements_history)

          nil
        end
      end
    end
  end
end
