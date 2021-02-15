# frozen_string_literal: true

module Authorizer
  class Operator < ServiceBase
    def call
      input = ARGF.read
      output = Authorizer::Processor.call(operation_stream: parse(input))
      puts output
    end

    private

    def parse(input)
      input.split(/\n/).map { |line| JSON.parse(line) }
    end
  end
end
