# frozen_string_literal: true

# Dependencies
require 'date'
require 'json'
require 'as-duration'

# Helpers
require_relative 'authorizer/helpers/time_interval'

# API
require_relative 'authorizer/service_base'

require_relative 'authorizer/account_statement/base_statement'
require_relative 'authorizer/account_statement/creation_statement'
require_relative 'authorizer/account_statement/transaction_statement'

require_relative 'authorizer/account_statement/violations/context'
require_relative 'authorizer/account_statement/violations/strategy'
require_relative 'authorizer/account_statement/violations/transaction/' \
                 'account_not_initialized_strategy'
require_relative 'authorizer/account_statement/violations/transaction/' \
                 'card_not_active_strategy'
require_relative 'authorizer/account_statement/violations/transaction/' \
                'insufficient_limit_strategy'
require_relative 'authorizer/account_statement/violations/transaction/' \
                  'high_frequency_strategy'
require_relative 'authorizer/account_statement/violations/transaction/' \
                  'double_transaction_strategy'

require_relative 'authorizer/account_statement/violations/creation/' \
                 'account_already_initialized_strategy'

require_relative 'authorizer/account_statement/adapters/base_adapter'
require_relative 'authorizer/account_statement/adapters/creation_statement_adapter'
require_relative 'authorizer/account_statement/adapters/transaction_statement_adapter'
require_relative 'authorizer/account_statement/builder_adapter_delegator'
require_relative 'authorizer/account_statement/builder'

require_relative 'authorizer/processor'
require_relative 'authorizer/operator'

require_relative 'authorizer/version'

module Authorizer
end
