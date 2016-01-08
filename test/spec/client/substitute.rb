require_relative './client_spec_init'

describe 'Client Substitute' do
  specify 'Standard Response Dialog is 501 Not Implemented' do
    request = Connection::Controls::Messages::Requests.example
    expected_response = Connection::Controls::Messages::Responses::NotImplemented.example

    connection = Connection::Client::Substitute.build
    connection.write request

    actual_response = connection.read
    assert actual_response == expected_response
  end

  describe 'Programming' do
    specify 'Request Matches Programmed Dialog' do
      request = Connection::Controls::Messages::Requests.example
      expected_response = Connection::Controls::Messages::Responses.example

      connection = Connection::Client::Substitute.build
      connection.program request, expected_response

      connection.write request

      actual_response = connection.read
      assert actual_response == expected_response
    end

    specify 'Request Does Not Match Programmed Dialog' do
      expected_request = Connection::Controls::Messages::Requests.example
      actual_request = Connection::Controls::Messages::Responses.example '/some-other-path'

      connection = Connection::Client::Substitute.build
      connection.program expected_request, 'doesnt-matter'

      connection.write actual_request

      begin
        connection.read
      rescue Connection::Client::Substitute::RequestMismatch => error
      end

      assert error
    end
  end
end
