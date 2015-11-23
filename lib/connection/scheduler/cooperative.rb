module Connection
  module Scheduler
    class Cooperative
      dependency :dispatcher, Reactor::Dispatcher
      dependency :logger, ::Telemetry::Logger
      dependency :fiber_manager, FiberSubstitute

      def self.build(dispatcher=nil)
        instance = new
        instance.dispatcher = dispatcher if dispatcher
        instance.fiber_manager = Fiber
        ::Telemetry::Logger.configure instance
        instance
      end

      def wait_readable(io)
        fiber = fiber_manager.current
        dispatcher.wait_readable io do
          fiber.resume
        end
        logger.trace "Pausing until readable (Fileno: #{io.fileno})"
        fiber_manager.yield
        logger.trace "IO is ready for reading (Fileno: #{io.fileno})"
      end

      def wait_writable(io)
        fiber = fiber_manager.current
        dispatcher.wait_writable io do
          fiber.resume
        end
        logger.trace "Pausing until writable (Fileno: #{io.fileno})"
        fiber_manager.yield
        logger.trace "IO is ready for writing (Fileno: #{io.fileno})"
      end
    end
  end
end
