# frozen_string_literal: true

RSpec.describe Authorizer::Helpers::TimeInterval do
  describe '#in_minutes_interval?' do
    let(:end_time) { Time.now }

    it 'confirms times inside an interval' do
      expect(
        described_class.in_minutes_interval?(
          start_time: end_time,
          end_time: end_time,
          interval: 0
        )
      ).to be true

      expect(
        described_class.in_minutes_interval?(
          start_time: end_time - 59.seconds,
          end_time: end_time,
          interval: 1
        )
      ).to be true
    end

    it 'denies times outside an interval' do
      expect(
        described_class.in_minutes_interval?(
          start_time: end_time - 1.second,
          end_time: end_time,
          interval: 0
        )
      ).to be false

      expect(
        described_class.in_minutes_interval?(
          start_time: end_time - 5.minutes,
          end_time: end_time,
          interval: 4
        )
      ).to be false
    end
  end
end
