# frozen_string_literal: true

RSpec.describe Artsy::EventPublisher do
  it "has a version number" do
    expect(Artsy::EventPublisher::VERSION).not_to be nil
  end
end
