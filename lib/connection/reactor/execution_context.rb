module Connection
  class Reactor
    class ExecutionContext
      dependency :logger, Telemetry::Logger

      attr_accessor :blk
      attr_reader :dispatcher
      attr_reader :process
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
        self.blk = blk
        start_fiber
        resume nil
      end

      def start_fiber
        @fiber = Fiber.new do
          logger.trace "Running process"
          begin
            policy = Policy::Cooperative.build self
            process.change_connection_policy policy
            process.start
            blk.(process) if blk
          rescue => error
            blk.(process, error) if blk
            raise error
          end
        end
      end

      def resume(return_value)
        logger.trace "Resuming fiber: #{self}"
        fiber.resume return_value
      end

      def spawn(child_process)
        logger.trace "Building child process"
        child_context = self.class.build child_process, dispatcher
        logger.debug "Built child process"
        logger.trace "Starting child process"
        child_context.start &blk
        logger.debug "Started child process"
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
