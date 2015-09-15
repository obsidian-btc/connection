module Connection
  module Policy
    class Cooperative
      class Action
        class Puts < Action
          def write?
            true
          end

          def handle(*lines)
            # TODO: implement a non blocking version
            Immediate.puts socket, *lines
          end
        end
      end
    end
  end
end
