module Connection
  module Policy
    class Cooperative
      class Action
        class Gets < Action
          def read?
            true
          end

          def handle(separator_or_limit = nil, limit = nil)
            # TODO: implement a non blocking version
            Immediate.gets socket, separator_or_limit, limit
          end
        end
      end
    end
  end
end
