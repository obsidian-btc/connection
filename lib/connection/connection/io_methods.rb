module Connection
  module IOMethods
    def gets(separator_or_limit = nil, limit = nil)
      logger.trace "gets(#{separator_or_limit.inspect}, #{limit.inspect})"
      return_value = policy.gets socket, separator_or_limit, limit
      logger.debug "gets read #{return_value.to_s.size} bytes"
      logger.data "Data: #{return_value}"
      return_value
    end

    def puts(*lines)
      logger.trace "puts(#{lines.map(&:inspect) * ", " })"
      policy.puts socket, *lines
      logger.debug "puts returned"
      nil
    end

    def read(bytes = nil)
      logger.trace "read(#{bytes})"
      return_value = policy.read socket, bytes
      logger.debug "read #{return_value.size} bytes"
      logger.data "Data: #{return_value}"
      return_value
    end

    def write(data)
      logger.trace "write(#{data.inspect})"
      return_value = policy.write socket, data
      logger.debug "wrote #{return_value.to_i} bytes"
      return_value
    end
  end
end
