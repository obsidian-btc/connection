module Connection
  class Reactor
    class ExecutionContext
      dependency :logger, Telemetry::Logger

      attr_accessor :blk
      attr_reader :dispatcher
      attr_reader :process_name
      attr_reader :process
      attr_reader :fiber

      def initialize(process, dispatcher, process_name)
        @child_index = 0
        @dispatcher = dispatcher
        @process_name = process_name
        @process = process
      end

      def self.build(process, dispatcher, process_name = nil)
        process_name ||= default_name process
        instance = new process, dispatcher, process_name
        Telemetry::Logger.configure instance
        instance
      end

      def self.default_name(process)
        process.class.name
      end

      def next_child_index
        @child_index += 1
      end

      def resume(return_value)
        logger.trace "Resuming: (Process: #{process_name}, Fiber: #{fiber})"
        return_value = fiber.resume return_value
        logger.debug "Resumed: (Process: #{process_name}, Fiber: #{fiber})"
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
            logger.trace "Starting process (Process: #{process_name}, Fiber: #{Fiber.current})"
            process.start
            logger.debug "Process finished (Process: #{process_name}), Fiber: #{Fiber.current}"
            blk.(process) if blk
          rescue => error
            logger.debug "Process errored (Process: #{process_name}, Fiber: #{Fiber.current}, Error: #{error.class.name})"
            blk.(process, error) if blk
            raise error
          end
        end
      end

      def spawn(child_process)
        name = "#{process_name}-child-#{next_child_index}"
        child_context = self.class.build child_process, dispatcher, name
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
