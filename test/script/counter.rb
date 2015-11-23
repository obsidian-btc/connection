require_relative './script_init'

if ENV['SSL'] == 'on'
  client_ssl_context, server_ssl_context = Connection::Controls::SSL.context_pair
end

counter = (ENV['COUNTER'] || '3').to_i

reactor, scheduler = Connection::Controls.example_reactor_loop

reactor.add_fiber do
  server = Connection.server 2000, scheduler, ssl: server_ssl_context
  client = server.accept

  reactor.add_fiber do
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
end

reactor.add_fiber do
  client = Connection.client '127.0.0.1', 2000, scheduler: scheduler, ssl: client_ssl_context

  until counter.zero?
    request = "old-counter=#{counter}"

    client.write request

    response = client.read

    __logger.info "Read response: #{response.inspect}"
    *, new_counter = response.split '=', 2
    counter = new_counter.to_i
  end
end

reactor.start

fail unless counter.zero?
