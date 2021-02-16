# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      module Transaction
        class CardNotActiveStrategy < Strategy
          def rule_name
            'card-not-active'
          end

          def violation?(statements_history:, **)
            latest_statement = statements_history[-1]

            !latest_statement.nil? && !latest_statement.active_card
          end
        end
      end
    end
  end
end
