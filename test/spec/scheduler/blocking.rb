require_relative './scheduler_spec_init'

describe 'Blocking Scheduling' do
  def spawn_thread(&block)
    thread = Thread.new do
      Thread.current.abort_on_exception = true
      block.()
    end
    Thread.pass until thread.status == 'sleep' || !thread.alive?
    thread
  end

  describe 'Waiting Until File is Readable' do
    scheduler = Connection::Scheduler::Blocking.new 1

    specify 'Returns After File is Readable' do
      read_io, write_io = Connection::Controls::IO.blocked_read_pair
      output = nil

      spawn_thread do
        scheduler.wait_readable read_io
        output = read_io.read_nonblock 12
      end

      write_io.write 'some-message'
      Thread.pass until output

      assert output == 'some-message'
    end
  end

  describe 'Waiting Until File is Writable' do
    scheduler = Connection::Scheduler::Blocking.new 1

    specify 'Returns After File is Writable' do
      read_io, write_io, bytes_in_write_buffer =
        Connection::Controls::IO.blocked_write_pair

      thread = spawn_thread do
        scheduler.wait_writable write_io
        write_io.write 'some-message'
      end

      read_io.read_nonblock bytes_in_write_buffer
      Thread.pass while thread.alive?

      output = read_io.read_nonblock 12

      assert output == 'some-message'
    end
  end
end
