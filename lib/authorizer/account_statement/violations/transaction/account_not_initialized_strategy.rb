# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      module Transaction
        class AccountNotInitializedStrategy < Strategy
          def rule_name
            'account-not-initialized'
          end

          def violation?(statements_history:, **)
            latest_statement = statements_history[-1]

            latest_statement.nil? || latest_statement.violations.include?(rule_name)
          end
        end
      end
    end
  end
end
