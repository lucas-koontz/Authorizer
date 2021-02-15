# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      module Transaction
        class HighFrequencyStrategy < Strategy
          def rule_name
            'high-frequency-small-interval'
          end

          def violation?(event:, statements_history:)
            time = Time.parse(event[:time])

            high_frequency?(statements_history: statements_history, time: time)
          end

          private

          def high_frequency?(statements_history:, time:)
            max_transactions = 3
            interval = 2

            transactions = 0

            statements_history.reverse_each do |statement|
              if statement.time.nil? || !statement.violations.empty?
                countinue
              elsif Helpers::TimeInterval.in_minutes_interval?(
                start_time: statement.time,
                end_time: time,
                interval: interval
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
