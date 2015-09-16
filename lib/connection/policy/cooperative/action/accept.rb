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

            def run(&blk)
              connection = Server::Client.build socket
              blk.(connection) if block_given?
              handler.(connection)
            end
          end
        end
      end
    end
  end
end
