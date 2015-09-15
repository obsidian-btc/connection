module Connection
  class Client
    include Proxy.new(:gets, :puts, :read, :write)

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

    def socket
      @socket ||= TCPSocket.new host, port
    end
  end
end
