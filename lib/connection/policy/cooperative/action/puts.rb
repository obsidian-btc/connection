module Connection
  module Policy
    class Cooperative
      class Action
        class Puts < Action
          def write?
            true
          end

          def handle(*lines)
            socket.puts *lines
          end
        end
      end
    end
  end
end
