require_relative "./reactor_tests_init"

module ErrorGenerator
  class Error < StandardError
    def to_s
      "raises-error"
    end
  end

  def self.run
    raise Error
  end
end

errors = {}

reactor = Connection::Reactor.build
reactor.register ErrorGenerator
begin
  reactor.run do |client, error|
    if error
      errors[client.to_s] = error.to_s
    end
  end
rescue ErrorGenerator::Error
end

assert errors, :equals => { "ErrorGenerator" => "raises-error" }
