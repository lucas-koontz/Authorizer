# frozen_string_literal: true

module Authorizer
  module AccountStatement
    class Builder < ServiceBase
      def call(raw_operation:, statements_history:)
        @raw_operation = raw_operation
        adapter.new(raw_operation: raw_operation, statements_history: statements_history).build
      end

      private

      attr_reader :raw_operation

      def adapter
        @adapter ||= BuilderAdapterDelegator.new(raw_operation).adapter
      end
    end
  end
end
