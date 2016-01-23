require_relative './scheduler_spec_init'

describe 'Cooperative Scheduling' do
  describe 'Waiting Until File is Readable' do
    specify 'Resumes After File is Readable' do
      scheduler = Connection::Scheduler::Cooperative.new

      Connection::Controls::IO.blocked_read_pair do |read_io, write_io|
        dispatcher = Connection::Controls::CooperativeDispatcher.new

        scheduler.dispatcher = dispatcher
        scheduler.fiber_manager.attach_yield_action do
          dispatcher.trigger
        end

        scheduler.wait_readable read_io
      end

      assert scheduler.fiber_manager.context_switched?
    end
  end

  describe 'Waiting Until File is Writable' do
    specify 'Resumes After File is Writable' do
      scheduler = Connection::Scheduler::Cooperative.new

      Connection::Controls::IO.blocked_write_pair do |read_io, write_io|
        dispatcher = Connection::Controls::CooperativeDispatcher.new

        scheduler.dispatcher = dispatcher
        scheduler.fiber_manager.attach_yield_action do
          dispatcher.trigger
        end

        scheduler.wait_writable write_io
      end

      assert scheduler.fiber_manager.context_switched?
    end
  end
end
