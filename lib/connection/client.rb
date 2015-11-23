module Connection
  class Client
    include Connection

    attr_reader :io

    def initialize(io)
      @io = io
    end

    def self.build(io, scheduler=nil)
      instance = new io
      instance.configure_dependencies scheduler: scheduler
      instance
    end

    def close
      io.close
      telemetry.closed

    rescue IOError => error
      telemetry.closed
      raise error
    end

    def readline(*arguments)
      readline_command.(*arguments)
    end
    alias_method :gets, :readline

    def max_read_size
      8192
    end

    def readline_command
      @readline_command ||= readline.build io, scheduler
    end

    def read(bytes=nil, outbuf=nil)
      bytes ||= max_read_size

      logger.trace "Reading (Bytes Requested: #{bytes}, Fileno: #{fileno.inspect})"

      data = Operation.read to_io, scheduler do
        io.read_nonblock bytes, outbuf
      end

      logger.debug "Read (Size: #{data.bytesize}, Bytes Requested: #{bytes}, Fileno: #{fileno.inspect})"
      logger.data data

      telemetry.read data

      data

    rescue IOError => error
      telemetry.closed
      raise error

    rescue Errno::ECONNRESET => error
      telemetry.connection_reset
      raise error
    end

    def telemetry
      @telemetry ||= Telemetry.new
    end

    def write(data)
      logger.trace "Writing (Size: #{data.bytesize}, Fileno: #{fileno.inspect})"
      logger.data data

      bytes_written = Operation.write to_io, scheduler do
        io.write_nonblock data
      end

      logger.debug "Wrote (Size: #{bytes_written}, Fileno: #{fileno.inspect})"

      telemetry.wrote data, bytes_written

      bytes_written

    rescue Errno::EPIPE => error
      telemetry.broken_pipe
      raise error
    end
  end
end
