module Connection
  module Scheduler
    class Blocking
      attr_reader :poll_interval_ms

      dependency :logger, ::Telemetry::Logger

      def initialize(poll_interval_ms)
        @poll_interval_ms = poll_interval_ms
      end

      def self.build
        instance = new 5_000
        ::Telemetry::Logger.configure instance
        instance
      end

      def self.configure(receiver)
        receiver.scheduler = instance
      end

      def self.instance
        @instance ||= build
      end

      def poll_interval
        @poll_interval ||= Rational(poll_interval_ms, 1000)
      end

      def wait_readable(io)
        return if io.is_a? StringIO
        loop do
          ready_io, * = IO.select [io], [], [], poll_interval
          break if ready_io
        end
      end

      def wait_writable(io, &block)
        return if io.is_a? StringIO
        loop do
          ready_io, * = IO.select [], [io], [], poll_interval
          break if ready_io
        end
      end
    end
  end
end
