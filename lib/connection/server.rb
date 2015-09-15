module Connection
  class Server
    include Connection

    attr_reader :host
    attr_reader :port

    def initialize(host, port)
      @host = host
      @port = port
    end

    def accept
      logger.trace "accept"
      client_socket = policy.accept socket
      new_instance = Client.build client_socket
      new_instance.policy = policy
      logger.debug "accept returned socket #{client_socket.fileno}"
      new_instance
    end

    def socket
      @socket ||= TCPServer.new host, port
    end
  end
end
