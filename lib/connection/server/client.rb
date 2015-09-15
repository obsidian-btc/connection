module Connection
  class Server
    class Client
      include Proxy.new(:close, :gets, :puts, :read, :write)

      attr_reader :socket

      dependency :logger

      def initialize(socket)
        @socket = socket
      end

      def self.build(socket)
        instance = new socket
        Telemetry::Logger.configure instance
        instance
      end
    end
  end
end
