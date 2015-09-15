module Connection
  class Client
    include Proxy.new(:close, :gets, :puts, :read, :write)

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
      @socket ||= policy.connect host, port
    end

    def connected?
      if @socket then true else false end
    end
  end
end
