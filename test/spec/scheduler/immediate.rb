require_relative './scheduler_spec_init'

describe 'Immediate Scheduling' do
  describe 'Waiting Until File is Readable' do
    specify 'Returns Immediately' do
      io, * = Connection::Controls.blocked_read_pair
      scheduler = Connection::Scheduler::Immediate.new

      scheduler.wait_readable io

      begin
        io.read_nonblock 1
      rescue IO::EAGAINWaitReadable => error
      end

      assert error
    end
  end

  describe 'Waiting Until File is Writable' do
    specify 'Returns Immediately' do
      *, io, _ = Connection::Controls.blocked_write_pair
      scheduler = Connection::Scheduler::Immediate.new

      scheduler.wait_writable io

      begin
        io.write_nonblock '.'
      rescue IO::EAGAINWaitReadable => error
      end

      assert error
    end
  end
end
