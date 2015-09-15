module Connection
  class Reactor
    DEFAULT_SELECT_INTERVAL = 0.5

    attr_accessor :client_count
    attr_reader :dispatcher
    attr_reader :select_interval

    dependency :logger, Telemetry::Logger

    def initialize(dispatcher, select_interval)
      @client_count = 0
      @dispatcher = dispatcher
      @select_interval = select_interval
    end

    def self.build
      dispatcher = Dispatcher.build
      instance = new dispatcher, DEFAULT_SELECT_INTERVAL
      Telemetry::Logger.configure instance
      instance
    end

    def register(client)
      logger.debug "Registering client #{client}"
      fiber = Fiber.new do
        client.run do |connection|
          policy = Policy::Cooperative.new self
          connection.policy = policy
        end
        unregister client
      end
      increment_client_count
      fiber.resume
    end

    def unregister(client)
      logger.debug "Unregistering client #{client}"
      decrement_client_count
    end

    def wait_readable(socket, &handler)
      logger.debug "Registering handler for reading on fd=#{socket.fileno}"
      dispatcher.register_read socket, &handler
    end

    def wait_writable(socket, &handler)
      logger.debug "Registering handler for writing on fd=#{socket.fileno}"
      dispatcher.register_write socket, &handler
    end

    def decrement_client_count
      self.client_count -= 1
    end

    def increment_client_count
      self.client_count += 1
    end

    def run
      while client_count > 0
        reads, writes = dispatcher.pending_sockets

        if reads.empty? and writes.empty?
          logger.debug "Nothing to read or write, sleeping for a tick"
          sleep select_interval and next
        end

        logger.trace "Selecting: reads=#{reads.map(&:fileno).inspect}, writes=#{writes.map(&:fileno).inspect}"
        ready_reads, ready_writes, _ = IO.select reads, writes, [], select_interval
        ready_reads ||= []
        ready_writes ||= []

        logger.debug "Selected: reads=#{ready_reads.map(&:fileno).inspect}, writes=#{ready_writes.map(&:fileno).inspect}"
        next unless ready_reads and ready_writes

        ready_reads.each do |ready_socket|
          dispatcher.dispatch_read ready_socket
        end

        ready_writes.each do |ready_socket|
          dispatcher.dispatch_write ready_socket
        end
      end
    end
  end
end
