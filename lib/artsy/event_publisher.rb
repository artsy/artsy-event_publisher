# frozen_string_literal: true

require_relative "event_publisher/version"
require "bunny"

module Artsy
  module EventPublisher
    class Error < StandardError; end

    def self.publish(topic, routing_key = "", subject: nil, verb: nil, object: nil, properties: nil)
      return unless Config.enabled

      data = {
        subject: subject,
        verb: verb,
        object: object,
        properties: properties
      }.compact
      payload = data.to_json
      Connection.publish(topic: topic, routing_key: routing_key, payload: payload)
      Config.logger&.debug("[event] #{payload}")
      data
    end

    def self.configure
      yield Config if block_given?
      Config
    end

    module Config
      extend self

      attr_accessor :app_id
      attr_accessor :enabled
      attr_accessor :rabbitmq_url
      attr_accessor :logger
    end

    class Connection
      OPTIONS = {
        persistent: true,
        content_type: "application/json",
        headers: {}
      }
      @connection = nil
      @mutex = Mutex.new

      def self.publish(topic:, routing_key:, payload:)
        with_channel do |channel|
          options = OPTIONS.merge(routing_key: routing_key, app_id: Config.app_id)
          channel.topic(topic, durable: true).publish(payload, options)
          raise Error, "Publishing failed" unless channel.wait_for_confirms
        end
      end

      def self.with_channel
        channel = get_connection.create_channel
        channel.confirm_select
        yield channel if block_given?
      ensure
        channel.close if channel&.open?
      end

      # Synchronized access to the connection
      def self.get_connection
        @mutex.synchronize do
          @connection ||= build_connection
          @connection = build_connection if @connection.closed?
          @connection
        end
      end

      def self.build_connection
        Bunny.new(Config.rabbitmq_url).tap(&:start)
      end
    end
  end
end
