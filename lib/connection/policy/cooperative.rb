module Connection
  module Policy
    class Cooperative
      def self.build(reactor)
        instance = new reactor
        Telemetry::Logger.configure instance
        instance
      end

      attr_reader :reactor
      attr_accessor :fiber

      dependency :logger, Telemetry::Logger

      def initialize(reactor)
        @reactor = reactor
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
