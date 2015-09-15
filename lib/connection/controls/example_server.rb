module Connection
  module Controls
    class ExampleServer
      attr_reader :server_connection

      dependency :logger, Telemetry::Logger

      def initialize(server_connection)
        @server_connection = server_connection
      end

      def self.build
        connection = Connection::Server.build "127.0.0.1", 90210
        instance = new connection
        Telemetry::Logger.configure instance
        instance
      end

      def run(&blk)
        blk.(server_connection) if block_given?

        (0..Float::INFINITY).each do |number|
          logger.debug "Iteration ##{number}"

          client_connection = server_connection.accept

          first_line = client_connection.gets
          number_of_bytes = first_line.to_i

          input_data = client_connection.read number_of_bytes
          counter = input_data.to_i
          output_data = (counter - 1).to_s
          logger.info "Writing back #{output_data.inspect}"

          response = "#{output_data.size}\n#{output_data}"
          client_connection.write response

          client_connection.close

          return if counter <= 1
        end
      end
    end
  end
end
