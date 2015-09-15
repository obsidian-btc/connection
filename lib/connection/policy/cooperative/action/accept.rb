module Connection
  module Policy
    class Cooperative
      class Action
        class Accept < Action
          def read?
            true
          end

          def handle
            socket.accept_nonblock
          end
        end
      end
    end
  end
end
