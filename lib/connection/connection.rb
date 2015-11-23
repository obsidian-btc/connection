module Connection
  def self.client(host, port, scheduler: nil, ssl: nil)
    socket = TCPSocket.new host, port

    if ssl
      ssl_context = if ssl == true then self.ssl_context else ssl end
      socket = OpenSSL::SSL::SSLSocket.new socket, ssl_context

      instance = Client::SSL.build socket, scheduler
      instance.handshake
      instance
    else
      Client.build socket, scheduler
    end
  end

  def self.ssl_context(context)
    fail 'Construct default SSL context (perhaps with settings that point to cert/key)'
  end

  def self.server(port, scheduler=nil, ssl: nil)
    tcp_server = TCPServer.new port

    if ssl
      ssl_context = if ssl == true then self.ssl_context else ssl end
      ssl_socket = OpenSSL::SSL::SSLServer.new tcp_server, ssl_context

      Server::SSL.build ssl_socket, scheduler
    else
      Server.build tcp_server, scheduler
    end
  end

  def self.included(cls)
    cls.dependency :logger, ::Telemetry::Logger
    cls.dependency :scheduler, Scheduler
    cls.dependency :telemetry, Telemetry
  end

  def close
    io.close
    telemetry.closed

  rescue IOError => error
    telemetry.closed
    raise error
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

    Telemetry.configure self
  end

  def io
    fail
  end

  def fileno
    to_io.fileno
  end

  def to_io
    if io.respond_to? :to_io
      io.to_io
    else
      io
    end
  end
end
