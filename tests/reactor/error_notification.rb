require_relative "./reactor_tests_init"

module ErrorGenerator
  class Error < StandardError
    def to_s
      "raises-error"
    end
  end

  def self.start
    raise Error
  end

  def self.change_connection_policy(policy)
  end
end

errors = {}
reraised = false

reactor = Connection::Reactor.build
reactor.register ErrorGenerator
begin
  reactor.run do |client, error|
    if error
      errors[client.to_s] = error.to_s
    end
  end
rescue ErrorGenerator::Error
  reraised = true
end

assert errors, :equals => { "ErrorGenerator" => "raises-error" }
assert reraised
