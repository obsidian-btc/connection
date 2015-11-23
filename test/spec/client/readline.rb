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
end
