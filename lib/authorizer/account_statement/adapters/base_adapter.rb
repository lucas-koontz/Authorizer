# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Adapters
      class BaseAdapter
        attr_reader :raw_operation, :statements_history

        def initialize(raw_operation:, statements_history:)
          @raw_operation = raw_operation
          @statements_history = statements_history
        end

        def build
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def build_instance(active_card:, available_limit:)
          klass.new(
            active_card: active_card,
            available_limit: available_limit,
            operation: operation,
            violations: violations
          )
        end

        def build_instance_with_violations
          build_instance(
            active_card: lastest_statement.active_card,
            available_limit: lastest_statement.available_limit
          )
        end

        def klass
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def operation_id
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def operation
          @operation ||= raw_operation[operation_id]
        end

        def violations
          @violations ||= violation_strategies.map do |strategy|
            context.strategy = strategy
            context.verify
          end.compact
        end

        def context
          @context ||= Violations::Context.new(operation: operation,
                                               statements_history: statements_history)
        end

        def violation_strategies
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def lastest_statement
          @lastest_statement ||= statements_history[-1]
        end
      end
    end
  end
end
