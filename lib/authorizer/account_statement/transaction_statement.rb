# frozen_string_literal: true

module Authorizer
  module AccountStatement
    class TransactionStatement < BaseStatement
      def merchant
        @merchant ||= event[:merchant]
      end

      def time
        @time ||= DateTime.parse(event[:time])
      end
    end
  end
end
