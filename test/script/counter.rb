require_relative './script_init'

require 'process_host'

if ENV['SSL'] == 'on'
  @client_ssl_context, @erver_ssl_context = Connection::Controls::SSL.context_pair
end

def client_ssl_context
  @client_ssl_context
end

def server_ssl_context
  @server_ssl_context
end

class Client
  attr_accessor :counter

  def initialize(counter)
    @counter = counter
  end

  def start
    until counter.zero?
      request = "old-counter=#{counter}"

      connection.write request

      response = connection.read

      __logger.info "Read response: #{response.inspect}"
      *, new_counter = response.split '=', 2
      self.counter = new_counter.to_i
    end
  end

  def connection
    @connection ||= Connection.client '127.0.0.1', 2113, ssl: client_ssl_context
  end

  module ProcessHostIntegration
    def change_connection_scheduler(scheduler)
      connection.scheduler = scheduler
    end
  end
end

class Server
  def start
    client = connection.accept

    loop do
      request = client.read

      __logger.info "Read request: #{request.inspect}"
      *, client_counter = request.split '=', 2
      new_counter = client_counter.to_i - 1
      response = "new-counter=#{new_counter}"

      client.write response

      break if new_counter.zero?
    end
  end

  def connection
    @connection ||= Connection.server 2113, ssl: server_ssl_context
  end

  module ProcessHostIntegration
    def change_connection_scheduler(scheduler)
      connection.scheduler = scheduler
    end
  end
end

counter = (ENV['COUNTER'] || '3').to_i
client = Client.new counter
server = Server.new

cooperation = ProcessHost::Cooperation.build
cooperation.register server, 'some-server'
cooperation.register client, 'some-client'
cooperation.start
