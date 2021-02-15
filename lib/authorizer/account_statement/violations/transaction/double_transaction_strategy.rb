# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      module Transaction
        class DoubleTransactionStrategy < Strategy
          def rule_name
            'double-transaction'
          end

          def violation?(operation:, statements_history:)
            time = Time.parse(operation[:time])
            merchant = operation[:merchant]
            amount = operation[:amount]

            similar_transaction?(
              statements_history: statements_history,
              time: time,
              merchant: merchant,
              amount: amount
            )
          end

          private

          def similar_transaction?(statements_history:, time:, merchant:, amount:)
            interval = 2

            statements_history.reverse_each do |statement|
              if statement.time.nil? || !statement.violations.empty?
                countinue
              elsif Helpers::TimeInterval.in_minutes_interval?(
                start_time: statement.time,
                end_time: time,
                interval: interval
              )
                return true if statement.merchant.eql?(merchant) && statement.amount == amount
              end
            end

            false
          end
        end
      end
    end
  end
end
