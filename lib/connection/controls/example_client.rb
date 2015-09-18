module Connection
  module Controls
    class ExampleClient
      attr_reader :connection
      attr_accessor :counter

      dependency :logger, Telemetry::Logger

      def initialize(connection, counter)
        @connection = connection
        @counter = counter
      end

      def self.build(port, counter: nil)
        counter ||= ENV.fetch("EXAMPLE_CLIENT_COUNTER", "3").to_i
        connection = Connection::Client.build "127.0.0.1", port
        instance = new connection, counter
        Telemetry::Logger.configure instance
        instance
      end

      def start
        (1..Float::INFINITY).each do |number|
          logger.debug "Iteration ##{number}"

          output_data = counter.to_s
          connection.puts output_data.size
          connection.write output_data

          first_line = connection.gets
          number_of_bytes = first_line.to_i

          input_data = connection.read number_of_bytes
          self.counter = input_data.to_i

          logger.info "Counter is #{counter.inspect}"
          connection.close

          return if counter.zero?
        end
      end

      def change_connection_policy(policy)
        connection.policy = policy
      end
    end
  end
end
