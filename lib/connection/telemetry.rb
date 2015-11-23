module Connection
  class Telemetry
    include Observable

    attr_accessor :bytes_received
    attr_accessor :bytes_sent
    attr_accessor :closed_connections
    attr_reader :records
    attr_accessor :open_connections

    dependency :clock, Clock::UTC

    def initialize
      @records = []
      @bytes_received = 0
      @bytes_sent = 0
      @open_connections = 0
      @closed_connections = 0
    end

    def self.build
      instance = new
      Clock::UTC.configure instance
      instance
    end

    def self.configure(receiver)
      instance = build
      receiver.telemetry = instance
      instance
    end

    def broken_pipe
      record :broken_pipe
    end

    def broken_pipe?
      records.any? { |record| record.operation == :broken_pipe }
    end

    def closed
      record :closed
    end

    def closed?
      records.any? { |record| record.operation == :closed }
    end

    def connection_closed
      self.open_connections -= 1
      self.closed_connections += 1
    end

    def connection_reset
      record :connection_reset
    end

    def connection_reset?
      records.any? { |record| record.operation == :connection_reset }
    end

    def pretty_print
      JSON.pretty_generate records.map(&:to_h)
    end

    def read(data)
      record :read, data
      self.bytes_received += data.bytesize
    end

    def record(operation, data=nil)
      changed
      timestamp = clock.iso8601
      record = Record.new operation, data, timestamp
      records << record
      notify_observers record
    end

    def total_connections
      open_connections + closed_connections
    end

    def wrote(data, bytes_written)
      data = data.encode 'ASCII-8BIT'
      written = data.slice! 0, bytes_written
      record :wrote, written
      self.bytes_sent += bytes_written
    end

    Record = Struct.new :operation, :data, :timestamp do
      def to_h
        hash = { :operation => operation, :time => timestamp.to_s }
        hash[:data] = data if data
        hash
      end
    end

    class Substitute
      def self.build
        Telemetry.new
      end
    end
  end
end
