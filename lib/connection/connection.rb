module Connection
  def self.client(host, port, scheduler: nil, ssl_context: nil)
    establish_connection = Client::EstablishConnection.build(
      host,
      port,
      ssl_context: ssl_context
    )
    Client.build establish_connection, scheduler
  end

  def self.server(port, scheduler: nil, ssl_context: nil)
    tcp_server = TCPServer.new '0.0.0.0', port

    if ssl_context
      ssl_socket = OpenSSL::SSL::SSLServer.new tcp_server, ssl_context

      Server::SSL.build ssl_socket, scheduler
    else
      Server.build tcp_server, scheduler
    end
  end

  def self.included(cls)
    cls.dependency :logger, ::Telemetry::Logger
    cls.dependency :scheduler, Scheduler
    cls.send :include, IOProxy
  end

  def configure_dependencies(scheduler: nil)
    ::Telemetry::Logger.configure self

    if scheduler
      self.scheduler = scheduler
    else
      Scheduler::Blocking.configure self
    end
  end
end
