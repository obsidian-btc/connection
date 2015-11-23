require_relative './scheduler_spec_init'

describe 'Cooperative Scheduling' do
  describe 'Waiting Until File is Readable' do
    specify 'Resumes After File is Readable' do
      read_io, write_io = Connection::Controls::IO.blocked_read_pair
      dispatcher = Connection::Controls::CooperativeDispatcher.new

      scheduler = Connection::Scheduler::Cooperative.new
      scheduler.dispatcher = dispatcher
      scheduler.fiber_manager.attach_yield_action do
        dispatcher.trigger
      end

      scheduler.wait_readable read_io

      assert scheduler.fiber_manager.context_switched?
    end
  end

  describe 'Waiting Until File is Writable' do
    specify 'Resumes After File is Writable' do
      read_io, write_io = Connection::Controls::IO.blocked_write_pair
      dispatcher = Connection::Controls::CooperativeDispatcher.new

      scheduler = Connection::Scheduler::Cooperative.new
      scheduler.dispatcher = dispatcher
      scheduler.fiber_manager.attach_yield_action do
        dispatcher.trigger
      end

      scheduler.wait_writable read_io

      assert scheduler.fiber_manager.context_switched?
    end
  end
end
