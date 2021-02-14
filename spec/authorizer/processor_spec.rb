# frozen_string_literal: true

RSpec.describe Authorizer::Processor do
  describe '#call' do
    it 'can create a new account' do
      event_stream = [{ account: { "active-card": true, "available-limit": 100 } }]

      expect(described_class.call(event_stream: event_stream)).to eq(
        { account: { "active-card": true, "available-limit": 100 }, violations: [] }
      )
    end

    it 'can process a stream of transaction events' do
      event_stream = [
        { account: { "active-card": true, "available-limit": 100 } },
        { transaction: { merchant: 'Burger King', amount: 20, time: '2019-02-13T10:00:00.000Z' } },
        { transaction: { merchant: "Habbib\'s", amount: 10, time: '2019-02-13T11:00:00.000Z' } }
      ]

      expect(described_class.new(event_stream).process).to eq(
        [
          { account: { "active-card": true, "available-limit": 100 }, violations: [] },
          { account: { "active-card": true, "available-limit": 80 }, violations: [] },
          { account: { "active-card": true, "available-limit": 70 }, violations: [] }
        ]
      )
    end

    context 'violations' do
      
      describe 'account cannot be updated or recreated' do
        it 'does not allow create a new account ' do
          event_stream = [
            { account: { "active-card": true, "available-limit": 100 } },
            { account: { "active-card": true, "available-limit": 100 } }

          ]

          expect(described_class.new(event_stream).process).to eq(
            [
              { account: { "active-card": true, "available-limit": 100 }, violations: [] },
              { account: { "active-card": true, "available-limit": 100 },
                violations: ['account-already-initialized'] }
            ]
          )
        end

        it 'does not allow updating card status' do
          event_stream = [
            { account: { "active-card": true, "available-limit": 100 } },
            { account: { "active-card": false, "available-limit": 100 } }

          ]

          expect(described_class.new(event_stream).process).to eq(
            [
              { account: { "active-card": true, "available-limit": 100 }, violations: [] },
              { account: { "active-card": true, "available-limit": 100 },
                violations: ['account-already-initialized'] }
            ]
          )
        end

        it 'does not allow updating available limit' do
          event_stream = [
            { account: { "active-card": true, "available-limit": 100 } },
            { account: { "active-card": true, "available-limit": 90 } }

          ]

          expect(described_class.new(event_stream).process).to eq(
            [
              { account: { "active-card": true, "available-limit": 100 }, violations: [] },
              { account: { "active-card": true, "available-limit": 100 },
                violations: ['account-already-initialized'] }
            ]
          )
        end
      end

      describe 'without properly initializing an account' do
        it 'blocks transation' do
          event_stream = [
            { transaction: { merchant: 'Burger King', amount: 20,
                             time: '2019-02-13T10:00:00.000Z' } }
          ]

          expect(described_class.new(event_stream).process).to eq(
            [
              { account: { "active-card": false, "available-limit": 0 },
                violations: ['account-not-initialized'] }
            ]
          )
        end

        it 'allows an account to be initialized after violation' do
          event_stream = [
            { transaction: { merchant: 'Burger King', amount: 20,
                             time: '2019-02-13T10:00:00.000Z' } },
            { account: { "active-card": true, "available-limit": 100 } }
          ]

          expect(described_class.new(event_stream).process).to eq(
            [
              { account: { "active-card": false, "available-limit": 0 },
                violations: ['account-not-initialized'] },
              { account: { "active-card": true, "available-limit": 100 }, violations: [] }
            ]
          )
        end
      end

      it 'blocks transation when the card is not active' do
        event_stream = [
          { account: { "active-card": false, "available-limit": 100 } },
          { transaction: { merchant: 'Burger King', amount: 20, time: '2019-02-13T10:00:00.000Z' } }
        ]

        expect(described_class.new(event_stream).process).to eq(
          [
            { account: { "active-card": false, "available-limit": 100 }, violations: [] },
            { account: { "active-card": false, "available-limit": 100 },
              violations: ['card-not-active'] }
          ]
        )
      end

      it 'blocks transation when exceeding available limit' do
        event_stream = [
          { account: { "active-card": true, "available-limit": 100 } },
          { transaction: { merchant: 'Burger King', amount: 20, time: '2019-02-13T10:00:00.000Z' } },
          { transaction: { merchant: "Habbib\'s", amount: 110, time: '2019-02-13T11:00:00.000Z' } },
          { transaction: { merchant: "Habbib\'s", amount: 10, time: '2019-02-13T12:00:00.000Z' } }
        ]

        expect(described_class.new(event_stream).process).to eq(
          [
            { account: { "active-card": true, "available-limit": 100 }, violations: [] },
            { account: { "active-card": true, "available-limit": 80 }, violations: [] },
            { account: { "active-card": true, "available-limit": 80 }, violations: ['insufficient-limit'] },
            { account: { "active-card": true, "available-limit": 70 }, violations: [] }
          ]
        )
        end

      it 'blocks transation when other 3 transactions occurred in the last 2 minutes' do
        event_stream = [
          { account: { "active-card": true, "available-limit": 100 } },
          { transaction: { merchant: 'Burger King', amount: 20, time: '2019-02-13T10:00:00.000Z' } },
          { transaction: { merchant: "Habbib\'s", amount: 30, time: '2019-02-13T10:00:30.000Z' } },
          { transaction: { merchant: "Starbucks", amount: 10, time: '2019-02-13T10:01:00.000Z' } },
          { transaction: { merchant: "Kalunga", amount: 10, time: '2019-02-13T10:01:30.000Z' } },
          { transaction: { merchant: "McDonald's", amount: 15, time: '2019-02-13T10:02:01.000Z' } }
        ]

        expect(described_class.new(event_stream).process).to eq(
          [
            { account: { "active-card": true, "available-limit": 100 }, violations: [] },
            { account: { "active-card": true, "available-limit": 80 }, violations: [] },
            { account: { "active-card": true, "available-limit": 50 }, violations: [] } ,
            { account: { "active-card": true, "available-limit": 40 }, violations: [] } ,
            { account: { "active-card": true, "available-limit": 40 }, violations: ['high-frequency-small-interval'] },
            { account: { "active-card": true, "available-limit": 25 }, violations: [] }
          ]
        )
      end

      it 'blocks transation when a similar transaction occured in the last 2 minutes' do
        event_stream = [
          { account: { "active-card": true, "available-limit": 100 } },
          { transaction: { merchant: 'Burger King', amount: 20, time: '2019-02-13T10:00:00.000Z' } },
          { transaction: { merchant: "Burger King", amount: 20, time: '2019-02-13T10:01:30.000Z' } },
          { transaction: { merchant: "Burger King", amount: 20, time: '2019-02-13T10:02:01.000Z' } }
        ]

        expect(described_class.new(event_stream).process).to eq(
          [
            { account: { "active-card": true, "available-limit": 100 }, violations: [] },
            { account: { "active-card": true, "available-limit": 80 }, violations: [] },
            { account: { "active-card": true, "available-limit": 80 }, violations: ['doubled-transaction'] },
            { account: { "active-card": true, "available-limit": 60 }, violations: [] }
          ]
        )
      end
    end
  end
end
