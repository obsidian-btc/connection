require_relative './client_spec_init'

describe 'Client Substitute' do
  describe 'Reading' do
    describe 'Expected' do
      specify 'Unspecified Length' do
        connection = Connection::Client::Substitute.build
        connection.expect_read 'some-text'

        data = connection.read

        assert data == 'some-text'
      end

      specify 'Specific Length' do
        connection = Connection::Client::Substitute.build
        connection.expect_read 'some-text'

        data = connection.read 4

        assert data == 'some'
      end
    end

    describe 'Unexpected' do
      specify 'Nothing Programmed' do
        connection = Connection::Client::Substitute.build

        begin
          connection.read
        rescue IOError => error
        end

        assert error
      end

      specify 'Write is Programmed' do
        connection = Connection::Client::Substitute.build
        connection.expect_write 'some-text'

        begin
          connection.read
        rescue IOError => error
        end

        assert error
      end
    end
  end

  describe 'Reading a Line' do
    specify 'Expected' do
      connection = Connection::Client::Substitute.build
      connection.expect_read "foo\rbar\nbaz"

      lines = []
      lines << connection.readline("\r")
      lines << connection.readline
      lines << connection.readline

      assert lines == ["foo\r", "bar\n", "baz"]
    end

    describe 'Unexpected' do
      specify 'Nothing Programmed' do
        connection = Connection::Client::Substitute.build

        begin
          connection.readline
        rescue IOError => error
        end

        assert error
      end

      specify 'Write is Programmed' do
        connection = Connection::Client::Substitute.build
        connection.expect_write 'some-text'

        begin
          connection.readline
        rescue IOError => error
        end

        assert error
      end
    end
  end

  describe 'Writing' do
    describe 'Expected' do
      specify 'In Full' do
        connection = Connection::Client::Substitute.build
        connection.expect_write 'some-text'

        connection.write 'some-text'

        assert connection.current_expectation.is_a?(Connection::Client::Substitute::Expectation::None)
      end

      specify 'Partial' do
        connection = Connection::Client::Substitute.build
        connection.expect_write 'some-text'

        connection.write 'some'

        refute connection.current_expectation.is_a?(Connection::Client::Substitute::Expectation::None)
      end
    end

    describe 'Unexpected' do
      specify 'Nothing Programmed' do
        connection = Connection::Client::Substitute.build

        begin
          connection.write 'some-text'
        rescue IOError => error
        end

        assert error
      end

      specify 'Different Text is Programmed' do
        connection = Connection::Client::Substitute.build
        connection.expect_write 'some-text'

        begin
          connection.write 'some-other-text'
        rescue IOError => error
        end

        assert error
      end

      specify 'Read is Programmed' do
        connection = Connection::Client::Substitute.build
        connection.expect_read 'some-text'

        begin
          connection.write 'some-text'
        rescue IOError => error
        end

        assert error
      end
    end
  end

  specify 'Closing' do
    connection = Connection::Client::Substitute.build

    refute connection.closed?

    connection.close

    assert connection.closed?
  end
end
