# frozen_string_literal: true

module Authorizer
  class Processor < ServiceBase
    # expect operation_stream to be array of Hash
    def call(operation_stream:)
      statements_history = []

      operation_stream.each do |operation|
        statements_history << AccountStatement::Builder.call(
          raw_operation: operation,
          statements_history: statements_history
        )
      end

      statements_history
    end
  end
end
