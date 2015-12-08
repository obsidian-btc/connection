module Connection
  module IOProxy
    def close
      io.close
    end

    def closed?
      io.closed?
    end

    def fileno
      if closed?
        nil
      else
        to_io.fileno
      end
    end

    def io
      fail
    end

    def to_io
      if io.respond_to? :to_io
        io.to_io
      else
        io
      end
    end
  end
end
