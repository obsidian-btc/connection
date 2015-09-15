module Connection
  module Policy
    class Cooperative
      attr_reader :reactor
      attr_reader :retry_interval
      attr_accessor :fiber

      dependency :logger, Telemetry::Logger

      def initialize(reactor, retry_interval)
        @reactor = reactor
        @retry_interval = retry_interval
      end

      def self.build(reactor, retry_interval = nil)
        retry_interval ||= Connection::RETRY_INTERVAL
        instance = new reactor, retry_interval
        Telemetry::Logger.configure instance
        instance
      end

      def connect(host, port)
        TCPSocket.new host, port
      rescue Errno::ECONNREFUSED => error
        Timer.(reactor, retry_interval)
        retry
      end

      def accept(server_socket, *arguments)
        Action::Accept.(reactor, server_socket, arguments)
      end

      def gets(socket, *arguments)
        Action::Gets.(reactor, socket, arguments)
      end

      def puts(socket, *arguments)
        Action::Puts.(reactor, socket, arguments)
      end

      def read(socket, *arguments)
        Action::Read.(reactor, socket, arguments)
      end

      def write(socket, *arguments)
        Action::Write.(reactor, socket, arguments)
      end
    end
  end
end
