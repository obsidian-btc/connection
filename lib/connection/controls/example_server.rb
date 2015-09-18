module Connection
  module Controls
    class ExampleServer
      attr_reader :server_connection

      dependency :logger, Telemetry::Logger

      def initialize(server_connection)
        @server_connection = server_connection
      end

      def self.build(port)
        connection = Connection::Server.build "127.0.0.1", port
        instance = new connection
        Telemetry::Logger.configure instance
        instance
      end

      def start
        running = true

        (0..Float::INFINITY).each do |number|
          return unless running

          logger.debug "Iteration ##{number}"

          server_connection.accept do |client_connection|
            counter = handle_client client_connection
            running = false if counter <= 1
          end
        end
      end

      def change_connection_policy(policy)
        server_connection.policy = policy
      end

      def handle_client(client_connection)
        first_line = client_connection.gets
        number_of_bytes = first_line.to_i

        input_data = client_connection.read number_of_bytes
        counter = input_data.to_i
        output_data = (counter - 1).to_s
        logger.info "Writing back #{output_data.inspect}"

        response = "#{output_data.size}\n#{output_data}"
        client_connection.write response

        client_connection.close
        counter
      end
    end
  end
end
