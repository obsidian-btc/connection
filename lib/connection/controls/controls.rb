module Connection
  module Controls
    # Connects a client and a server through actual Connection objects. The
    # remote connection corresponds to the client, the local connection
    # corresponds to the server's connection to the client, and server
    # corresponds to the port binding.
    def self.pair(port=nil, &block)
      port ||= 2000

      server = Connection.server port
      remote = Connection.client '127.0.0.1', port
      local = server.accept

      remote.io.sync = true
      local.io.sync = true

      block.(remote, local, server)

    ensure

      remote.close if remote && !remote.closed?
      local.close if local && !local.closed?
      server.close
    end
  end
end
