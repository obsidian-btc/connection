module Connection
  module Policy
    class Cooperative
      class Action
        attr_reader :arguments
        attr_reader :fiber
        attr_reader :context
        attr_reader :socket

        dependency :logger

        def initialize(context, socket, arguments, fiber)
          @context = context
          @socket = socket
          @arguments = arguments
          @fiber = fiber
        end

        def self.build(context, socket, arguments)
          fiber = Fiber.current
          instance = new context, socket, arguments, fiber
          Telemetry::Logger.configure instance
          instance
        end

        def self.call(*arguments)
          instance = build *arguments
          instance.call
        end

        def read?
          false
        end

        def write?
          false
        end

        def call
          handler = method :handler

          if read?
            context.wait_readable socket, &handler
          elsif write?
            context.wait_writable socket, &handler
          else
            fail "Action #{self.class} is neither a read nor a write"
          end
        end

        def handler(_)
          return_value = handle *arguments
          context.resume return_value
        end
      end
    end
  end
end
