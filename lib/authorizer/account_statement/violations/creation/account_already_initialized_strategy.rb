# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      module Creation
        class AccountAlreadyInitializedStrategy < Strategy
          def rule_name
            'account-already-initialized'
          end

          def violation?(statements_history:, **)
            latest_statement = statements_history[-1]
            not_initialized = Transaction::AccountNotInitializedStrategy.new.rule_name

            !latest_statement.nil? && !latest_statement.violations.include?(not_initialized)
          end
        end
      end
    end
  end
end
