module Connection
  module Controls
    module Messages
      module Requests
        def self.example(path=nil)
          path ||= '/'

          <<-HTTP
GET #{path} HTTP/1.1\r
Host: www.example.com\r
Accept: */*\r
          HTTP
        end
      end

      module Responses
        def self.example(response_text=nil)
          response_text ||= 'some-message'

          <<-HTTP.chomp
HTTP/1.1 200 Ok\r
Content-Length: #{response_text.bytesize}\r
\r
#{response_text}
          HTTP
        end

        module NotImplemented
          def self.example
            "HTTP/1.1 501 Not Implemented\r\n"
          end
        end
      end
    end
  end
end
