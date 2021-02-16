# frozen_string_literal: true

module Authorizer
  module AccountStatement
    class BuilderAdapterDelegator
      attr_reader :operation

      def initialize(operation)
        @operation = operation
      end

      def adapter
        return Adapters::CreationStatementAdapter if operation['account']
        return Adapters::TransactionStatementAdapter if operation['transaction']
      end
    end
  end
end
