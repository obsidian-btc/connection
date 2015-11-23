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
      cls.build socket, scheduler
    end

    def accept
      logger.trace "Accepting Connection (Server Fileno: #{fileno})"

      socket = Operation.read to_io, scheduler do
        io.accept_nonblock
      end

      logger.debug "Accepted Connection (Client Fileno: #{socket.fileno}, Server Fileno: #{fileno})"

      build_client socket
    end
  end
end
