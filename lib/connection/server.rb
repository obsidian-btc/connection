module Connection
  class Server
    include Connection

    attr_reader :io

    def initialize(io)
      @io = io
    end

    def self.build(tcp_server, scheduler=nil)
      instance = new tcp_server
      instance.configure_dependencies scheduler: scheduler
      instance
    end

    def build_client(socket, cls=nil)
      cls ||= Client
      client = cls.build socket, scheduler
      client.telemetry.add_observer self
      client
    end

    def accept
      logger.trace "Accepting Connection (Server Fileno: #{fileno})"

      socket = Operation.read to_io, scheduler do
        io.accept_nonblock
      end

      telemetry.open_connections += 1

      logger.debug "Accepted Connection (Client Fileno: #{socket.fileno}, Server Fileno: #{fileno})"

      build_client socket
    end

    def update(telemetry_record)
      if telemetry_record.operation == :read
        telemetry.bytes_received += telemetry_record.data.bytesize
      elsif telemetry_record.operation == :wrote
        telemetry.bytes_sent += telemetry_record.data.bytesize
      elsif %i(closed broken_pipe connection_reset).include? telemetry_record.operation
        telemetry.connection_closed
      end
    end
  end
end
