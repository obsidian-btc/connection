module Connection
  module Telemetry
    def self.configure(receiver)
      cls =
        case receiver
        when Client then Client::Telemetry
        else return
        end

      cls.configure receiver
    end
  end
end
