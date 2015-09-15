module Connection
  class Reactor
    class ExecutionContext
      dependency :logger, Telemetry::Logger

      attr_reader :process
      attr_reader :dispatcher
      attr_reader :fiber

      def initialize(process, dispatcher)
        @process = process
        @dispatcher = dispatcher
      end

      def self.build(process, dispatcher)
        instance = new process, dispatcher
        Telemetry::Logger.configure instance
        instance
      end

      def start(&blk)
        @fiber = Fiber.new do
          logger.trace "Running process"
          begin
            process.run do |connection|
              policy = Policy::Cooperative.build self
              connection.policy = policy
            end
            blk.(process) if block_given?
          rescue => error
            blk.(process, error) if block_given?
          end
        end
        resume nil
      end

      def resume(return_value)
        logger.trace "Resuming fiber: #{self}"
        fiber.resume return_value
      end

      def wait_readable(socket, &handler)
        dispatcher.register_read socket, &handler
        logger.debug "Registered handler for reading on fd=#{socket.fileno}"
        Fiber.yield
      end

      def wait_writable(socket, &handler)
        dispatcher.register_write socket, &handler
        logger.debug "Registered handler for writing on fd=#{socket.fileno}"
        Fiber.yield
      end

      def wait_timer(milliseconds, &handler)
        dispatcher.register_timer milliseconds, &handler
        logger.debug "Registered handler to run after #{milliseconds}ms"
        Fiber.yield
      end
    end
  end
end
