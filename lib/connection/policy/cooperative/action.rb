module Connection
  module Policy
    class Cooperative
      class Action
        attr_reader :arguments
        attr_reader :fiber
        attr_reader :reactor
        attr_reader :socket

        dependency :logger

        def initialize(reactor, socket, arguments, fiber)
          @reactor = reactor
          @socket = socket
          @arguments = arguments
          @fiber = fiber
        end

        def self.build(reactor, socket, arguments)
          fiber = Fiber.current
          instance = new reactor, socket, arguments, fiber
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
            reactor.wait_readable socket, &handler
          elsif write?
            reactor.wait_writable socket, &handler
          else
            fail "Action #{self.class} is neither a read nor a write"
          end

          logger.debug "Client is transferring control back to reactor"
          Fiber.yield
        end

        def handler(_)
          return_value = handle *arguments
          logger.debug "Reactor is ready to return control back to client"
          fiber.resume return_value
        end
      end
    end
  end
end
