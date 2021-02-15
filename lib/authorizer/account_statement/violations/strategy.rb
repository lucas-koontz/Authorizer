# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Violations
      class Strategy
        def rule_name
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def violation?(_operation:, _statements_history:)
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end
      end
    end
  end
end
