# frozen_string_literal: true

module Authorizer
  module AccountStatement
    module Adapters
      class CreationStatementAdapter < BaseAdapter
        def build
          if violations.empty? # can create
            build_instance(active_card: operation[:'active-card'],
                           available_limit: operation[:"available-limit"])
          else
            build_instance_with_violations
          end
        end

        def klass
          CreationStatement
        end

        def operation_id
          :account
        end

        def violation_strategies
          [Violations::Creation::AccountAlreadyInitializedStrategy.new]
        end
      end
    end
  end
end
