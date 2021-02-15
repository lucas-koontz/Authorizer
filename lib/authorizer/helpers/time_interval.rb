# frozen_string_literal: true

module Authorizer
  module Helpers
    module TimeInterval
      class << self
        def in_minutes_interval?(start_time:, end_time:, interval:)
          interval.minutes.before(end_time) <= start_time
        end
      end
    end
  end
end
