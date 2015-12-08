module Connection
  def self.client(host, port, scheduler: nil, ssl_context: nil)
    socket = TCPSocket.new host, port

    if ssl_context
      socket = OpenSSL::SSL::SSLSocket.new socket, ssl_context

      instance = Client::SSL.build socket, scheduler
      instance.handshake
      instance
    else
      Client.build socket, scheduler
    end
  end

  def self.ssl_context
    fail 'Construct default SSL context (perhaps with settings that point to cert/key)'
  end

  def self.server(port, scheduler=nil, ssl_context: nil)
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
  end

  def close
    io.close
  end

  def closed?
    io.closed?
  end

  def configure_dependencies(scheduler: nil)
    ::Telemetry::Logger.configure self

    if scheduler
      self.scheduler = scheduler
    else
      Scheduler::Blocking.configure self
    end
  end

  def io
    fail
  end

  def fileno
    if closed?
      nil
    else
      to_io.fileno
    end
  end

  def to_io
    if io.respond_to? :to_io
      io.to_io
    else
      io
    end
  end
end
