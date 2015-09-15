module Connection
  def self.included(cls)
    cls.extend Build
    cls.send :dependency, :logger, Telemetry::Logger
  end

  module Build
    def build(*constructor_arguments)
      instance = new *constructor_arguments
      Telemetry::Logger.configure instance
      instance
    end
  end

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
