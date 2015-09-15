module Connection
  module Policy
    class Cooperative
      class Action
        class Write < Action
          def write?
            true
          end

          def handle(data)
            socket.write  data
          end
        end
      end
    end
  end
end
