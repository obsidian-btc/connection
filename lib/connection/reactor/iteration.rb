module Connection
  class Reactor
    class Iteration
      DEFAULT_SELECT_INTERVAL = 0.5

      attr_reader :dispatcher
      attr_reader :select_interval

      dependency :logger, Telemetry::Logger

      def initialize(dispatcher, select_interval)
        @dispatcher = dispatcher
        @select_interval = select_interval
      end

      def self.build(dispatcher)
        instance = new dispatcher, DEFAULT_SELECT_INTERVAL
        Telemetry::Logger.configure instance
        instance
      end

      def self.call(*arguments)
        instance = build *arguments
        instance.()
      end

      def call
        reads, writes = dispatcher.pending_sockets

        if reads.empty? and writes.empty?
          logger.debug "Nothing to read or write, sleeping for a tick"
          sleep select_interval and return
        end

        ready_reads, ready_writes, _ = select reads, writes

        dispatch_reads ready_reads
        dispatch_writes ready_writes
        dispatch_timers
      end

      def dispatch_reads(reads)
        reads.each do |ready_socket|
          dispatcher.dispatch_read ready_socket
        end
      end

      def dispatch_timers
        dispatcher.check_timers
      end

      def dispatch_writes(writes)
        writes.each do |ready_socket|
          dispatcher.dispatch_write ready_socket
        end
      end

      def select(reads, writes)
        logger.trace "Selecting: #{inspect_sockets reads, writes }"
        reads, writes = IO.select reads, writes, [], select_interval
        reads ||= []
        writes ||= []
        logger.debug "Selected: reads=#{inspect_sockets reads, writes}"
        return reads, writes
      end

      def inspect_sockets(reads, writes)
        read_fds = reads.map &:fileno
        write_fds = writes.map &:fileno
        "reads=#{read_fds * ", "}, writes=#{write_fds * ", "}"
      end
    end
  end
end
