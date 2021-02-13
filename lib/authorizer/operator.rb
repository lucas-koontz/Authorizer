# frozen_string_literal: true

module Authorizer
  class Operator < ServiceBase
    def call
      input = ARGF.read.split(/\n/) # transform into array
      output = Authorizer::Processor.call(event_stream: input)
      puts output
    end
  end
end
