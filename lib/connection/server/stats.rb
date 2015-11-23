module Connection
  class Server
    class Stats
      attr_accessor :broken_pipes
      attr_accessor :bytes_received
      attr_accessor :bytes_sent
      attr_accessor :closed_connections
      attr_accessor :reset_connections
      attr_accessor :total_connections

      def initialize
        @broken_pipes = 0
        @bytes_received = 0
        @bytes_sent = 0
        @closed_connections = 0
        @reset_connections = 0
        @total_connections = 0
      end

      def connection_opened
        self.total_connections += 1
      end

      def open_connections
        total_connections - terminated_connections
      end

      def terminated_connections
        closed_connections + reset_connections + broken_pipes
      end

      def update(telemetry_record)
        case telemetry_record.operation
        when :read
          self.bytes_received += telemetry_record.data.bytesize

        when :wrote
          self.bytes_sent += telemetry_record.data.bytesize

        when :connection_reset
          self.reset_connections += 1

        when :broken_pipe
          self.broken_pipes += 1

        when :closed
          self.closed_connections += 1

        end
      end
    end
  end
end
