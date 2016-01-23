require_relative './client_spec_init'

describe 'Reading a Single Line' do
  scheduler = Connection::Client::Scheduler::Immediate.instance

  specify 'Without Arguments' do
    io = StringIO.new "some-line\n"
    readline = Connection::Client::Readline.build scheduler

    line = readline.(io)

    assert line == "some-line\n"
  end

  specify 'With Alternative Separator' do
    io = StringIO.new "some-line\nother-line\r\n"
    readline = Connection::Client::Readline.build scheduler

    line = readline.(io, "\r\n")

    assert line == "some-line\nother-line\r\n"
  end

  specify 'With Limit and Default Separator' do
    io = StringIO.new "some-line\n"
    readline = Connection::Client::Readline.build scheduler

    line = readline.(io, nil, 4)

    assert line == 'some'
  end

  specify 'With Limit and Alternative Separator' do
    io = StringIO.new "some-line\nother-line\r\n"
    readline = Connection::Client::Readline.build scheduler

    line = readline.(io, "\r\n", 15)

    assert line == "some-line\nother"
  end

  specify 'Performance' do
    next unless ENV['BENCHMARK'] == 'on'

    Connection::Controls::IO.tcp_pair do |client, server|
      readline = Connection::Client::Readline.build

      require 'benchmark/ips'
      Benchmark.ips do |bm|
        bm.config :warmup => 1

        bm.report 'raw' do
          client.write "some-line\r\n"
          server.readline "\r\n"
        end

        bm.report 'readline' do
          client.write "some-line\r\n"
          readline.(server, "\r\n")
        end
      end
    end
  end
end
