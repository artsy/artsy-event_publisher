# Artsy::EventPublisher

Lightweight helper for publishing events to rabbitmq in a pattern consistent with Artsy's ecosystem.

## Installation

Add following line to your Gemfile

```ruby
gem "artsy-event_publisher"
```

## Usage

Example initialization:

```ruby
# config/initializers/artsy-event_publisher.rb
Artsy::EventPublisher.configure do |config|
  config.app_id = "my-app" # identifies RabbitMQ connection
  config.enabled = true # enable/disable publishing events
  config.rabbitmq_url = "amqp(s)://<user>:<pass>@<host>:<port>/<vhost>" # required
  config.logger = Rails.logger
end
```

Publishing a sample event:

```ruby
Artsy::EventPublisher.publish(
  "auctions", # topic
  "bidder.pending_approval", # routing key
  verb: "pending_approval",
  subject: {id: bidder.id.to_s, root_type: "Bidder", display: bidder.name},
  object: {id: sale.id.to_s, root_type: "Sale", display: sale.name},
  properties: {url: "..."} # optional additional properties
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem on your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/artsy/artsy-event_publisher.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
