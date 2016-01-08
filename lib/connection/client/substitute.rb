module Connection
  class Client
    class Substitute
      def self.build
        new
      end

      def dialogs
        @dialogs ||= []
      end

      def program(request, response)
        dialogs << [request, response]
      end

      def read
        if dialogs.empty?
          return "HTTP/1.1 501 Not Implemented\r\n"
        end

        expected_request, response = dialogs.shift

        if expected_request == request
          response
        else
          raise RequestMismatch
        end
      end

      def request
        request_io.string
      end

      def request_io
        @request_io ||= StringIO.new
      end

      def write(*arguments)
        request_io.write *arguments
      end

      RequestMismatch = Class.new StandardError
    end
  end
end
