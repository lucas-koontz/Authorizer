# frozen_string_literal: true

module Authorizer
  module AccountStatement
    class BaseStatement
      attr_reader :active_card, :available_limit, :violations

      def initialize(active_card:, available_limit:, operation:, violations: [])
        @active_card = active_card
        @available_limit = available_limit
        @violations = violations
        @operation = operation
      end

      def print
        JSON.generate(
          {
            account: {
              'active-card': active_card,
              'available-limit': available_limit,
              violations: violations
            }
          }
        )
      end

      protected

      attr_reader :operation
    end
  end
end
