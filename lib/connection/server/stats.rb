module Connection
  class Server
    class Stats
      attr_accessor :bytes_received
      attr_accessor :bytes_sent
      attr_accessor :closed_connections
      attr_accessor :open_connections

      def initialize
        @bytes_received = 0
        @bytes_sent = 0
        @open_connections = 0
        @closed_connections = 0
      end

      def connection_terminated
        self.open_connections -= 1
        self.closed_connections += 1
      end

      def total_connections
        open_connections + closed_connections
      end

      def update(telemetry_record)
        if telemetry_record.operation == :read
          self.bytes_received += telemetry_record.data.bytesize
        elsif telemetry_record.operation == :wrote
          self.bytes_sent += telemetry_record.data.bytesize
        elsif %i(closed broken_pipe connection_reset).include? telemetry_record.operation
          self.connection_terminated
        end
      end
    end
  end
end
