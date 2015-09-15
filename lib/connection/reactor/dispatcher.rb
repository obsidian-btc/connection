module Connection
  class Reactor
    class Dispatcher
      def self.build
        instance = new
        Telemetry::Logger.configure instance
        instance
      end

      attr_reader :pending_reads
      attr_reader :pending_writes

      dependency :logger, Telemetry::Logger

      def initialize
        @pending_reads = {}
        @pending_writes = {}
      end

      def dispatch_read(socket)
        handler = pending_reads.delete socket
        handler.(socket)
      end

      def dispatch_write(socket)
        handler = pending_writes.delete socket
        handler.(socket)
      end

      def pending_sockets
        reads = pending_reads.keys
        writes = pending_writes.keys
        return reads, writes
      end

      def register_read(io_resource, &handler)
        pending_reads[io_resource] = handler
      end

      def register_write(io_resource, &handler)
        pending_writes[io_resource] = handler
      end
    end
  end
end
