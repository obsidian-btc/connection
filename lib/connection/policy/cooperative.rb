module Connection
  module Policy
    class Cooperative
      attr_reader :context
      attr_reader :retry_interval
      attr_accessor :fiber

      dependency :logger, Telemetry::Logger

      def initialize(context, retry_interval)
        @context = context
        @retry_interval = retry_interval
      end

      def self.build(context, retry_interval = nil)
        retry_interval ||= Connection::RETRY_INTERVAL
        instance = new context, retry_interval
        Telemetry::Logger.configure instance
        instance
      end

      def connect(host, port)
        logger.trace "Connecting to #{host}:#{port}"
        socket = TCPSocket.new host, port
        logger.debug "Connected to #{host}:#{port}"
        socket
      rescue Errno::ECONNREFUSED => error
        logger.debug "Connection refused on #{host}:#{port}"
        Timer.(context, retry_interval)
        logger.trace "Retrying connection to #{host}:#{port}"
        retry
      end

      def accept(server_socket, *arguments)
        Action::Accept.(context, server_socket, arguments)
      end

      def gets(socket, *arguments)
        Action::Gets.(context, socket, arguments)
      end

      def puts(socket, *arguments)
        Action::Puts.(context, socket, arguments)
      end

      def read(socket, *arguments)
        Action::Read.(context, socket, arguments)
      end

      def write(socket, *arguments)
        Action::Write.(context, socket, arguments)
      end
    end
  end
end
