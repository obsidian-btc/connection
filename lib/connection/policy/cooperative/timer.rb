module Connection
  module Policy
    class Cooperative
      class Timer
        attr_reader :duration_ms
        attr_reader :context

        dependency :logger, Telemetry::Logger

        def initialize(context, duration_ms)
          @duration_ms = duration_ms
          @context = context
        end

        def self.build(context, duration_ms)
          instance = new context, duration_ms
          Telemetry::Logger.configure instance
          instance
        end

        def self.call(*arguments)
          instance = build *arguments
          instance.call
        end

        def call
          context.wait_timer duration_ms do
            logger.debug "Wait timer for #{duration_ms}ms returned"
            logger.trace "Returning control back to client for retry"
            context.resume nil
          end
        end
      end
    end
  end
end
