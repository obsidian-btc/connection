module Connection
  module Controls
    module SSL
      extend self

      def client_context
        context
      end

      def context(cert: nil, key: nil)
        ssl_context = OpenSSL::SSL::SSLContext.new
        ssl_context.set_params verify_mode: OpenSSL::SSL::VERIFY_NONE
        ssl_context.cert = cert if cert
        ssl_context.key = key if key
        ssl_context
      end

      def context_pair
        return client_context, server_context
      end

      def pair(port=nil, &block)
        port ||= 2001

        client_context, server_context = context_pair

        server = Connection.server port, ssl_context: server_context

        client_socket = TCPSocket.new '127.0.0.1', port
        ssl_socket = OpenSSL::SSL::SSLSocket.new client_socket, client_context

        establish_connection = -> { ssl_socket }

        client = Connection::Client::SSL.build establish_connection

        begin
          block.(server, client)

        ensure
          server.close unless server.closed?
          client.close unless client.closed?
        end
      end

      def self_signed_cert
        name = OpenSSL::X509::Name.parse 'CN=nobody/DC=example'
        key = OpenSSL::PKey::RSA.new 2048

        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = 0
        cert.not_before = Time.now
        cert.not_after = Time.now + 3600

        cert.public_key = key.public_key
        cert.subject = name
        cert.issuer = name
        cert.sign key, OpenSSL::Digest::SHA1.new

        return cert, key
      end

      def server_context
        cert, key = self_signed_cert
        context cert: cert, key: key
      end
    end
  end
end
