module Connection
  class Reactor
    attr_reader :contexts
    attr_reader :dispatcher

    dependency :logger, Telemetry::Logger

    def initialize(dispatcher)
      @contexts = []
      @dispatcher = dispatcher
    end

    def self.build
      dispatcher = Dispatcher.build
      instance = new dispatcher
      Telemetry::Logger.configure instance
      instance
    end

    def process_count
      contexts.size
    end

    def register(process)
      Connection::Reactor::InvalidProcess.verify process

      context = ExecutionContext.build process, dispatcher
      contexts << context
      logger.debug "Registered process #{process}"
    end

    module NullIntegration
      def start(*)
        raise InvalidProcess.new self
      end

      def change_connection_policy(*)
        raise InvalidProcess.new self
      end
    end

    class InvalidProcess < StandardError
      def self.verify(process)
        unless process.respond_to? :start and process.respond_to? :change_connection_policy
          raise new process
        end
      end

      attr_reader :process

      def initialize(process)
        @process = process
      end

      def to_s
        <<-MESSAGE.chomp
Object #{process.inspect} does not implement #start and #change_connection_policy"
        MESSAGE
      end
    end

    def run(&blk)
      start_contexts &blk

      while process_count > 0
        Iteration.(dispatcher)
      end
    end

    def start_contexts(&blk)
      contexts.each do |context|
        context.start do |process, error|
          unregister context
          blk.(process, error) if block_given?
        end
      end
    end

    def unregister(context)
      contexts.delete context
      logger.debug "Unregistered process #{context.process}"
    end
  end
end
