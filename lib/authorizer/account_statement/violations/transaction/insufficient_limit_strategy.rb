# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      module Transaction
        class InsufficientLimitStrategy < Strategy
          def rule_name
            'insufficient-limit'
          end

          def violation?(event:, statements_history:)
            latest_statement = statements_history[-1]

            !latest_statement.nil? && latest_statement.available_limit < event[:amount]
          end
        end
      end
    end
  end
end
