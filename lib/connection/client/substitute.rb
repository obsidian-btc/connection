module Connection
  class Client
    class Substitute
      attr_writer :closed

      def self.build
        new
      end

      def close
        self.closed = true
      end

      def closed
        @closed ||= false
      end

      def closed?
        if closed then true else false end
      end

      def current_expectation
        expectations.fetch 0 do
          Expectation::None.instance
        end
      end

      def expect_read(data)
        expectation = Expectation::Read.build data
        expectations << expectation
      end

      def expect_write(data)
        expectation = Expectation::Write.build data
        expectations << expectation
      end

      def expectations
        @expectations ||= []
      end

      def read(*arguments)
        output = current_expectation.read *arguments
        expectations.shift if current_expectation.eof?
        output
      end

      def readline(*arguments)
        output = current_expectation.readline *arguments
        expectations.shift if current_expectation.eof?
        output
      end

      def write(*arguments)
        output = current_expectation.write *arguments
        current_expectation.check!
        expectations.shift if current_expectation.finished?
        output
      end

      Expectation = Struct.new :data do
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

        def check!
          unless data.start_with? io.string
            logger.fail 'Did not write the expected data; expected:'
            logger.fail data
            logger.fail 'Actual:'
            logger.fail io.string
            logger.fail ''

            raise IOError
          end
        end

        def finished?
          io.string == data
        end
      end
    end
  end
end
