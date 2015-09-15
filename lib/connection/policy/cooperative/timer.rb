module Connection
  module Policy
    class Cooperative
      class Timer
        attr_reader :duration_ms
        attr_reader :fiber
        attr_reader :reactor

        dependency :logger, Telemetry::Logger

        def initialize(reactor, duration_ms, fiber)
          @duration_ms = duration_ms
          @fiber = fiber
          @reactor = reactor
        end

        def self.build(reactor, duration_ms)
          fiber = Fiber.current
          instance = new reactor, duration_ms, fiber
          Telemetry::Logger.configure instance
          instance
        end

        def self.call(*arguments)
          instance = build *arguments
          instance.call
        end

        def call
          reactor.wait_timer duration_ms do
            logger.debug "Wait timer for #{duration_ms}ms returned"
            logger.trace "Returning control back to client for retry"
            fiber.resume
          end
          logger.debug "Connection could not be established"
          logger.trace "Returning control back to reactor for at least #{duration_ms}ms" 
          Fiber.yield
        end
      end
    end
  end
end
