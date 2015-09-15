module Connection
  module Policy
    class Cooperative
      class Action
        class Gets < Action
          def read?
            true
          end

          def handle(separator_or_limit = nil, limit = nil)
            if limit
              socket.gets separator_or_limit, limit
            elsif separator_or_limit
              socket.gets separator_or_limit
            else
              socket.gets
            end
          end
        end
      end
    end
  end
end
