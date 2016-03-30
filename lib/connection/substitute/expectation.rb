class Connection
  class Substitute
    class Expectation < Struct.new :data
      dependency :logger, Telemetry::Logger

      def self.build(data=nil)
        instance = new data
        ::Telemetry::Logger.configure instance
        instance
      end

      def eof?
        io.eof?
      end

      def io
        @io ||= build_io
      end

      def read(*arguments)
        io.read *arguments
      end

      def readline(*arguments)
        io.readline *arguments
      end

      def write(data)
        io.write data
      end

      module Expectation::EOF
        def self.eof?
          true
        end

        def self.read
          ''
        end

        def self.readline
          raise EOFError
        end

        def self.write(data)
          raise Errno::EPIPE
        end
      end

      class Expectation::None < Expectation
        def self.instance
          @instance ||= build
        end

        def build_io
          io = StringIO.new
          io.close_read
          io.close_write
          io
        end
      end

      class Expectation::Read < Expectation
        def build_io
          io = StringIO.new data
          io.close_write
          io
        end
      end

      class Expectation::Write < Expectation
        def build_io
          io = StringIO.new
          io.close_read
          io
        end

        def verify_written
          unless data.start_with? io.string
            logger.error <<~MESSAGE
            Did not write the expected data; expected:
             
            #{data}
             
            Actual:
             
            #{io.string}
             
            MESSAGE

            raise IOError, "Data written to connection substitute did not match expectation (an error was logged with details)"
          end
        end

        def finished?
          io.string == data
        end
      end
    end
  end
end
