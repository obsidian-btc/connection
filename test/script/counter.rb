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

class Pattern
  attr_reader :counter

  def initialize(counter)
    @counter = counter
  end

  def self.call(counter)
    instance = new counter
    instance.to_s
  end

  def to_s
    str = ''

    counter.times do |value|
      str << "counter=#{value}\r"
    end

    str << "counter=#{counter}\r"
    str << "done\r"

    str << 'some-text ' * counter

    str
  end
end

class Client
  attr_accessor :counter
  attr_accessor :scheduler

  def initialize(counter)
    @counter = counter
  end

  def start
    until counter.zero?
      request = Pattern.(counter)

      connection.write request

      response = connection.read

      __logger.info "Read response: #{response.inspect}"
      *, new_counter = response.split '=', 2
      self.counter = new_counter.to_i
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
      counter = nil

      loop do
        line = client.readline("\r").chomp "\r"
        break if line == 'done'
        _, counter = line.split '=', 2
      end

      counter = counter.to_i

      client.read(counter * 10)

      __logger.info "Read counter: #{counter.inspect}"

      counter -= 1
      client.write "counter=#{counter}"
      break if counter.zero?
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
