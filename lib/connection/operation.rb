module Connection
  class Operation
    attr_reader :action
    attr_reader :io
    attr_accessor :retries
    attr_reader :max_retries

    dependency :logger, ::Telemetry::Logger
    dependency :scheduler, Scheduler

    def initialize(action, io, retries)
      @action = action
      @io = io
      @max_retries = retries
      @retries = 0
    end

    def self.build(io, scheduler=nil, &action)
      instance = new action, io, max_retries

      ::Telemetry::Logger.configure instance

      if scheduler
        instance.scheduler = scheduler
      else
        Scheduler.configure instance
      end

      instance
    end

    def self.max_retries
      10
    end

    def self.read(*arguments, &action)
      reader = Reader.build *arguments, &action
      reader.()
    end

    def self.write(*arguments, &action)
      writer = Writer.build *arguments, &action
      writer.()
    end

    # TODO: When ruby 2.3 gets merged (and jruby supports it), we can stop using
    # exceptions for flow control here.
    def call
      result = nil
      fileno = io.fileno unless io.closed?
      logger.trace "Invoking Action (Fileno: #{fileno.inspect})"

      (1..Float::INFINITY).each do |attempt|
        attempt += 1

        result = perform_action attempt
        break if result

        self.retries += 1
        raise RetryCountExceeded if retries == max_retries
        raise SystemStackError if attempt > max_attempts

        wait
      end

      logger.debug "Action Invoked Successfully (Fileno: #{fileno.inspect})"
      result
    end

    # This is a safeguard against an operation never completing.
    def max_attempts
      1_000_000
    end

    def perform_action(attempt=nil)
      action.(self, attempt)

    rescue IO::WaitReadable, IO::WaitWritable => error
      logger.debug "Action Raised Error (Error: #{error.class.name}, Fileno: #{io.fileno.inspect}, Attempt: #{attempt})"
      return nil
    end

    def reset_retries
      self.retries = 0
    end

    def wait
      scheduler.public_send wait_method, io
      true
    end

    def wait_method
      fail
    end

    class Reader < Operation
      def wait_method
        :wait_readable
      end
    end

    class Writer < Operation
      def wait_method
        :wait_writable
      end
    end

    RetryCountExceeded = Class.new Error
  end
end
