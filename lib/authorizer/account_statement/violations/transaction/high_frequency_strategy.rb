# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      module Transaction
        class HighFrequencyStrategy < Strategy
          def rule_name
            'high-frequency-small-interval'
          end

          def violation?(operation:, statements_history:)
            time = Time.parse(operation['time'])

            high_frequency?(statements_history: statements_history, time: time)
          end

          private

          def high_frequency?(statements_history:, time:)
            max_transactions = 3
            interval = 2
            transactions = 0

            statements_history.reverse_each do |statement|
              if statement.is_a?(Authorizer::AccountStatement::CreationStatement) ||
                 !statement.violations.empty?
                next
              elsif Helpers::TimeInterval.in_minutes_interval?(
                start_time: statement.time, end_time: time, interval: interval
              )
                return true if (transactions += 1) == max_transactions
              end
            end

            false
          end
        end
      end
    end
  end
end
