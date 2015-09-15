module Connection
  class Server
    include Proxy

    attr_reader :host
    attr_reader :port

    dependency :logger

    def initialize(host, port)
      @host = host
      @port = port
    end

    def self.build(host, port)
      instance = new host, port
      Telemetry::Logger.configure instance
      instance
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
