require_relative './scheduler_spec_init'

describe 'Immediate Scheduling' do
  describe 'Waiting Until File is Readable' do
    specify 'Returns Immediately' do
      error = nil

      Connection::Controls::IO.blocked_read_pair do |io, _|
        scheduler = Connection::Scheduler::Immediate.new

        scheduler.wait_readable io

        begin
          io.read_nonblock 1
        rescue IO::EAGAINWaitReadable => error
        end
      end

      assert error
    end
  end

  describe 'Waiting Until File is Writable' do
    specify 'Returns Immediately' do
      error = nil

      Connection::Controls::IO.blocked_write_pair do |_, io, _|
        scheduler = Connection::Scheduler::Immediate.new

        scheduler.wait_writable io

        begin
          loop do
            io.write_nonblock '.'
          end
        rescue IO::EAGAINWaitReadable => error
        end
      end

      assert error
    end
  end
end
