# frozen_string_literal: true

RSpec.describe Authorizer::Operator do
  subject { described_class.call }

  let(:input) { nil }

  before do
    allow(ARGF).to receive(:read).and_return(input)
  end

  context 'no violation event streams' do
    context 'creating a new account' do
      let(:input) do
        <<~HEREDOC
          { "account": { "active-card": true, "available-limit": 100 } }
        HEREDOC
      end

      let(:expected_output) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100,"violations":[]}}
        HEREDOC
      end

      it do
        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'process a stream of transaction operations' do
      let(:input) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100}}
          {"transaction":{"merchant":"Burger King","amount":20,"time":"2019-02-13T10:00:00.000Z" }}
          {"transaction":{"merchant":"Habbib's","amount":10,"time":"2019-02-13T11:00:00.000Z"} }
        HEREDOC
      end

      let(:expected_output) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100,"violations":[]}}
          {"account":{"active-card":true,"available-limit":80,"violations":[]}}
          {"account":{"active-card":true,"available-limit":70,"violations":[]}}
        HEREDOC
      end

      it do
        expect { subject }.to output(expected_output).to_stdout
      end
    end
  end

  context 'violations' do
    context 'account being altered' do
      let(:input) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100 }}
          {"account":{"active-card":true,"available-limit":350 }}
          {"account":{"active-card":false,"available-limit":100 }}
          {"account":{"active-card":false,"available-limit":10 }}
        HEREDOC
      end

      let(:expected_output) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100,"violations":[]}}
          {"account":{"active-card":true,"available-limit":100,"violations":["account-already-initialized"]}}
          {"account":{"active-card":true,"available-limit":100,"violations":["account-already-initialized"]}}
          {"account":{"active-card":true,"available-limit":100,"violations":["account-already-initialized"]}}
        HEREDOC
      end

      it do
        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'account not initialized' do
      let(:input) do
        <<~HEREDOC
          {"transaction":{"merchant":"Burger King","amount":20,"time":"2019-02-13T10:00:00.000Z" }}
          {"transaction":{"merchant":"Burger Queen","amount":10,"time":"2019-02-13T10:00:00.000Z" }}
          {"account":{"active-card":true,"available-limit":100 }}
        HEREDOC
      end

      let(:expected_output) do
        <<~HEREDOC
          {"account":{"active-card":false,"available-limit":0,"violations":["account-not-initialized"]}}
          {"account":{"active-card":false,"available-limit":0,"violations":["account-not-initialized","card-not-active","insufficient-limit"]}}
          {"account":{"active-card":true,"available-limit":100,"violations":[]}}
        HEREDOC
      end

      it do
        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'card not active' do
      let(:input) do
        <<~HEREDOC
          {"account":{"active-card":false,"available-limit":100 }}
          {"transaction":{"merchant":"Burger King","amount":20,"time":"2019-02-13T10:00:00.000Z" }}
        HEREDOC
      end

      let(:expected_output) do
        <<~HEREDOC
          {"account":{"active-card":false,"available-limit":100,"violations":[]}}
          {"account":{"active-card":false,"available-limit":100,"violations":["card-not-active"]}}
        HEREDOC
      end

      it do
        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'insufficient limit' do
      let(:input) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100 }}
          {"transaction":{"merchant":"Burger King","amount":20, "time":"2019-02-13T10:00:00.000Z" }}
          {"transaction":{"merchant":"Habbib's","amount":81, "time":"2019-02-13T11:00:00.000Z" }}
          {"transaction":{"merchant":"Habbib's","amount":10, "time":"2019-02-13T11:00:00.000Z" }}
        HEREDOC
      end

      let(:expected_output) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100,"violations":[]}}
          {"account":{"active-card":true,"available-limit":80,"violations":[]}}
          {"account":{"active-card":true,"available-limit":80,"violations":["insufficient-limit"]}}
          {"account":{"active-card":true,"available-limit":70,"violations":[]}}
        HEREDOC
      end

      it do
        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'high frequency transactions' do
      let(:input) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100}}
          {"transaction":{"merchant":"Burger King","amount":20,"time":"2019-02-13T10:00:00.000Z"}}
          {"transaction":{"merchant":"Habbib's","amount":30,"time":"2019-02-13T10:00:30.000Z"}}
          {"transaction":{"merchant":"Starbucks","amount":10,"time":"2019-02-13T10:01:00.000Z"}}
          {"transaction":{"merchant":"Kalunga","amount":10,"time":"2019-02-13T10:01:30.000Z"}}
          {"transaction":{"merchant":"McDonald's","amount":15,"time":"2019-02-13T10:02:01.000Z"}}
        HEREDOC
      end

      let(:expected_output) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100,"violations":[]}}
          {"account":{"active-card":true,"available-limit":80,"violations":[]}}
          {"account":{"active-card":true,"available-limit":50,"violations":[]}}
          {"account":{"active-card":true,"available-limit":40,"violations":[]}}
          {"account":{"active-card":true,"available-limit":40,"violations":["high-frequency-small-interval"]}}
          {"account":{"active-card":true,"available-limit":25,"violations":[]}}
        HEREDOC
      end

      it do
        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'double transactions in a 2 minutes interval' do
      let(:input) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100 }}
          {"transaction":{"merchant":"Burger King","amount":20, "time":"2019-02-13T10:00:00.000Z" }}
          {"transaction":{"merchant":"Amazon","amount":10, "time":"2019-02-13T10:00:10.000Z" }}
            {"transaction":{"merchant":"Burger King","amount":20, "time":"2019-02-13T10:01:30.000Z" }}
            {"transaction":{"merchant":"Burger King","amount":20, "time":"2019-02-13T10:02:01.000Z" }}
        HEREDOC
      end

      let(:expected_output) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":100,"violations":[]}}
          {"account":{"active-card":true,"available-limit":80,"violations":[]}}
          {"account":{"active-card":true,"available-limit":70,"violations":[]}}
          {"account":{"active-card":true,"available-limit":70,"violations":["doubled-transaction"]}}
          {"account":{"active-card":true,"available-limit":50,"violations":[]}}
        HEREDOC
      end

      it do
        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'insuficient limit and high frequency transaction' do
      let(:input) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":140}}
          {"transaction":{"merchant":"Burger King","amount":20,"time":"2019-02-13T10:00:00.000Z"}}
          {"transaction":{"merchant":"Habbib's","amount":30,"time":"2019-02-13T10:00:30.000Z"}}
          {"transaction":{"merchant":"Starbucks","amount":10,"time":"2019-02-13T10:01:00.000Z"}}
          {"transaction":{"merchant":"Habbib's","amount":90,"time":"2019-02-13T10:01:30.000Z"}}
        HEREDOC
      end

      let(:expected_output) do
        <<~HEREDOC
          {"account":{"active-card":true,"available-limit":140,"violations":[]}}
          {"account":{"active-card":true,"available-limit":120,"violations":[]}}
          {"account":{"active-card":true,"available-limit":90,"violations":[]}}
          {"account":{"active-card":true,"available-limit":80,"violations":[]}}
          {"account":{"active-card":true,"available-limit":80,"violations":["insufficient-limit","high-frequency-small-interval"]}}
        HEREDOC
      end

      it do
        expect { subject }.to output(expected_output).to_stdout
      end
    end
  end
end
