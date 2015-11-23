require_relative './spec_init'

describe 'Operation' do
  specify 'Returns the Result of a Successful Operation' do
    result = Connection::Controls.operation { 'some-result'}
    assert result == 'some-result'
  end

  specify 'Re-invokes the Operation if Nil is Returned by the Action' do
    counter = 3

    result = Connection::Controls.operation do
      counter -= 1
      'some-result' if counter.zero?
    end

    assert result == 'some-result'
  end

  specify 'Retries on EAGAIN' do
    counter = 3

    result = Connection::Controls.operation do
      counter -= 1
      raise IO::EAGAINWaitReadable if counter == 2
      raise IO::EAGAINWaitWritable if counter == 1
      counter
    end

    assert result.zero?
  end

  specify 'Invokes the Scheduler Before Retrying Action' do
    counter = 3

    operation = Connection::Controls::Operation.build do
      counter -= 1
      raise IO::EAGAINWaitReadable if counter == 2
      raise IO::EAGAINWaitWritable if counter == 1
      counter
    end
    operation.()

    assert operation.scheduler.context_switches == 2
  end

  specify 'Max Retries' do
    operation = Connection::Controls::Operation.build { nil }

    begin
      operation.()
    rescue Connection::Operation::RetryCountExceeded => error
    end

    assert error
  end

  describe 'Subclasses' do
    action = ->{true}
    io = StringIO.new

    specify 'Read Operation' do
      read_operation = Connection::Operation::Reader.build action, io
      assert read_operation.wait_method == :wait_readable
    end

    specify 'Write Operation' do
      read_operation = Connection::Operation::Writer.build action, io
      assert read_operation.wait_method == :wait_writable
    end
  end
end
