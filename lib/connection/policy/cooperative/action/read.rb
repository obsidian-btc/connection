module Connection
  module Policy
    class Cooperative
      class Action
        class Read < Action
          def read?
            true
          end

          def handle(bytes = nil)
            socket.read bytes
          end
        end
      end
    end
  end
end
