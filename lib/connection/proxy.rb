module Connection
  module Proxy
    attr_writer :policy
    attr_writer :socket

    def close
      socket.close
      self.socket = nil
    end

    def policy
      @policy ||= Policy::Immediate
    end
  end
end
