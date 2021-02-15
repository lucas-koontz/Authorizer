# frozen_string_literal: true

module Authorizer
  module AccountStatement
    class TransactionStatement < BaseStatement
      def merchant
        @merchant ||= operation[:merchant]
      end

      def time
        @time ||= Time.parse(operation[:time])
      end
    end
  end
end
