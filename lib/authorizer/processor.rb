# frozen_string_literal: true

module Authorizer
  class Processor < ServiceBase
    attr_reader :operation_stream

    def call(operation_stream:)
      operation_stream
    end

    def process; end
  end
end
