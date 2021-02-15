# frozen_string_literal: true

module Authorizer
  module AccountStatement
    class BuilderAdapterDelegator
      attr_reader :event

      def initialize(event)
        @event = event
      end

      def adapter
        return Adapters::CreationStatementAdapter if event[:account]
        return Adapters::TransactionStatementAdapter if event[:transaction]
      end
    end
  end
end
