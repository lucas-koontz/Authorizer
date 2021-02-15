# frozen_string_literal: true

module Authorizer
  class Processor < ServiceBase
    attr_reader :event_stream

    def call(event_stream:)
      event_stream
    end

    def process; end
  end
end
