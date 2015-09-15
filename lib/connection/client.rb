module Connection
  class Client
    include Connection
    include Connection::IOMethods

    attr_reader :host
    attr_reader :port

    def initialize(host, port)
      @host = host
      @port = port
    end

    def socket
      @socket ||= TCPSocket.new host, port
    end
  end
end
