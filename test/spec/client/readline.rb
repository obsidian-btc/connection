require_relative './client_spec_init'

describe 'Reading a Single Line' do
  scheduler = Connection::Client::Scheduler::Immediate.instance

  specify 'Without Arguments' do
    io = StringIO.new "some-line\n"
    readline = Connection::Client::Readline.build io, scheduler

    line = readline.()

    assert line == "some-line\n"
  end

  specify 'With Alternative Separator' do
    io = StringIO.new "some-line\nother-line\r\n"
    readline = Connection::Client::Readline.build io, scheduler

    line = readline.("\r\n")

    assert line == "some-line\nother-line\r\n"
  end

  specify 'With Limit and Default Separator' do
    io = StringIO.new "some-line\n"
    readline = Connection::Client::Readline.build io, scheduler

    line = readline.(nil, 4)

    assert line == 'some'
  end

  specify 'With Limit and Alternative Separator' do
    io = StringIO.new "some-line\nother-line\r\n"
    readline = Connection::Client::Readline.build io, scheduler

    line = readline.("\r\n", 15)

    assert line == "some-line\nother"
  end

  specify 'Performance' do
    next unless ENV['BENCHMARK'] == 'on'
    Connection::Controls::IO.tcp_pair do |client, server|
      readline = Connection::Client::Readline.build server

      require 'benchmark/ips'
      Benchmark.ips do |bm|
        bm.config :warmup => 1

        bm.report 'raw' do
          client.write "some-line\r\n"
          server.readline "\r\n"
        end

        bm.report 'readline' do
          client.write "some-line\r\n"
          readline.("\r\n")
        end
      end
    end
  end
end
