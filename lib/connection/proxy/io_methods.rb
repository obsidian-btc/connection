module Connection
  module Proxy::IOMethods
    module Accept
      def accept(&blk)
        logger.trace "Proxying `accept'"
        policy.accept socket, blk
        logger.debug "Proxied `accept'"
      end
    end

    module Close
      def close
        socket.close
        self.socket = nil
      end
    end

    module Gets
      def gets(separator_or_limit=nil, limit=nil)
        logger.trace "Proxying `gets' (Separator or Limit: #{separator_or_limit.inspect}, Limit: #{limit.inspect})"
        return_value = policy.gets socket, separator_or_limit, limit
        return_value = return_value.to_s
        logger.debug "Proxied `gets' (Bytes Read: #{return_value.size})"
        logger.data return_value
        return_value
      end
    end

    module Puts
      def puts(*lines)
        logger.trace "Proxying `puts' (Lines: #{lines.size})"
        lines.each do |line|
          logger.data line
        end
        policy.puts socket, *lines
        logger.debug "Proxied `puts'"
        nil
      end
    end

    module Read
      def read(bytes=nil)
        logger.trace "Proxying `read' (Bytes to Read: #{bytes})"
        return_value = policy.read socket, bytes
        logger.debug "Proxied `read' (Bytes Read: #{return_value.size})"
        logger.data return_value
        return_value
      end
    end

    module Write
      def write(data)
        data = data.to_s
        logger.trace "Proxying `write' (Bytes to Write: #{data.size})"
        logger.data data
        return_value = policy.write socket, data
        logger.debug "Proxied `write' (Bytes Written: #{return_value.to_i})"
        return_value
      end
    end
  end
end
