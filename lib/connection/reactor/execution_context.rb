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

      def process_name
        process.class.name
      end

      def resume(return_value)
        logger.trace "Resuming: (Fiber: #{fiber}, Process: #{process_name})"
        return_value = fiber.resume return_value
        logger.debug "Resumed: (Fiber: #{fiber}, Process: #{process_name})"
        return_value
      end

      def start(&blk)
        self.blk = blk
        start_fiber
        resume nil
      end

      def start_fiber
        @fiber = Fiber.new do
          begin
            policy = Policy::Cooperative.build self
            process.change_connection_policy policy
            logger.trace "Starting process (Process: #{process_name})"
            process.start
            logger.debug "Process finished (Process: #{process_name})"
            blk.(process) if blk
          rescue => error
            logger.debug "Process errored (Process: #{process_name}, Error: #{error.class.name})"
            blk.(process, error) if blk
            raise error
          end
        end
      end

      def spawn(child_process)
        child_context = self.class.build child_process, dispatcher
        logger.trace "Starting subprocess (Execution Context: #{child_context.process_name})"
        child_context.start &blk
        logger.debug "Started subprocess (Execution Context: #{child_context.process_name})"
      end

      def wait_readable(socket, &handler)
        dispatcher.register_read socket, &handler
        logger.trace "Waiting for read (Fileno: #{socket.fileno})"
        return_value = Fiber.yield
        logger.debug "Read is ready (Fileno: #{socket.fileno})"
        return_value
      end

      def wait_writable(socket, &handler)
        dispatcher.register_write socket, &handler
        logger.trace "Waiting for write (Fileno: #{socket.fileno})"
        return_value = Fiber.yield
        logger.debug "Write is ready (Fileno: #{socket.fileno})"
        return_value
      end

      def wait_timer(milliseconds, &handler)
        dispatcher.register_timer milliseconds, &handler
        logger.trace "Waiting for timer (Duration: #{milliseconds}ms)"
        return_value = Fiber.yield
        logger.trace "Timer is finished (Duration: #{milliseconds}ms)"
        return_value
      end
    end
  end
end
