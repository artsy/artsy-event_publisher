# frozen_string_literal: true

RSpec.describe Artsy::EventPublisher do
  let(:sample_args) do
    [
      "auctions",
      "bidder.pending_approval",
      verb: "pending_approval",
      subject: {id: bidder.id.to_s, root_type: "Bidder", display: bidder.name},
      object: {id: sale.id.to_s, root_type: "Sale", display: sale.name}
    ]
  end

  it "has a version number" do
    expect(Artsy::EventPublisher::VERSION).not_to be nil
  end

  describe "configuration" do
    {
      app_id: "my-app",
      enabled: true,
      rabbitmq_url: "amqp://user:pass@rabbitmq.example.com/%2F",
      logger: Logger.new($stdout)
    }.each do |key, val|
      it "sets and gets #{key}" do
        Artsy::EventPublisher.configure { |config| config.send(:"#{key}=", val) }
        expect(Artsy::EventPublisher::Config.send(key.to_sym)).to eq(val)
      end
    end
  end

  describe "disabling" do
    it "avoids connects to rabbitmq" do
      Artsy::EventPublisher.configure { |config| config.enabled = false }
      expect(Artsy::EventPublisher::Connection).not_to receive(:publish)
      Artsy::EventPublisher.publish("topic", "routing_key", subject: {})
    end
  end

  describe "publishing" do
    it "connects to rabbitmq" do
      Artsy::EventPublisher.configure { |config| config.enabled = true }
      expect(Artsy::EventPublisher::Connection).to receive(:publish).with(
        topic: "topic",
        routing_key: "routing_key",
        payload: '{"subject":{"id":"1"},"properties":{"hi":"bye"}}'
      )
      Artsy::EventPublisher.publish("topic", "routing_key", subject: {id: "1"}, properties: {hi: "bye"})
    end
  end
end
