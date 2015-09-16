module Connection
  module Policy
    class Cooperative
      class Action
        class Accept < Action
          def read?
            true
          end

          def handle(blk)
            socket = self.socket.accept_nonblock
            child_process = ClientProcess.new blk, socket
            context.spawn child_process
          end

          class ClientProcess
            attr_reader :handler
            attr_reader :socket

            def initialize(handler, socket)
              @handler = handler
              @socket = socket
            end

            def start
              handler.(connection)
            end

            def change_connection_policy(policy)
              connection.policy = policy
            end

            def connection
              @connection ||= Server::Client.build socket
            end
          end
        end
      end
    end
  end
end
