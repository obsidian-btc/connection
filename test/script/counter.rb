require_relative './script_init'

require 'process_host'

if ENV['SSL'] == 'on'
  $client_ssl_context, $server_ssl_context = Connection::Controls::SSL.context_pair
end

def client_ssl_context
  $client_ssl_context
end

def server_ssl_context
  $server_ssl_context
end

class Client
  attr_accessor :counter
  attr_accessor :scheduler

  def initialize(counter)
    @counter = counter
  end

  def start
    until counter.zero?
      request = "old-counter=#{counter}\n"

      connection.write request

      response = connection.readline

      __logger.info "Read response: #{response.inspect}"
      *, new_counter = response.split '=', 2
      self.counter = new_counter.chomp.to_i
    end
  end

  def connection
    @connection ||= Connection.client(
      '127.0.0.1',
      2113,
      scheduler: scheduler,
      ssl_context: client_ssl_context
    )
  end

  module ProcessHostIntegration
    def change_connection_scheduler(scheduler)
      self.scheduler = scheduler
    end
  end
end

class Server
  attr_accessor :scheduler

  def start
    client = connection.accept

    loop do
      request = client.readline

      __logger.info "Read request: #{request.inspect}"
      *, client_counter = request.split '=', 2
      new_counter = client_counter.chomp.to_i - 1
      response = "new-counter=#{new_counter}\n"

      client.write response

      break if new_counter.zero?
    end
  end

  def connection
    @connection ||= Connection.server(
      2113,
      scheduler: scheduler,
      ssl_context: server_ssl_context
    )
  end

  module ProcessHostIntegration
    def change_connection_scheduler(scheduler)
      self.scheduler = scheduler
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
