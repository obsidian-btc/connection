module Connection
  class Reactor
    class Dispatcher
      class Substitute
        attr_reader :pending_actions

        def initialize
          @pending_actions = []
        end

        def self.build
          instance = new
          instance
        end

        def trigger
          pending_actions.each &:call
          pending_actions.clear
        end

        def wait_readable(io, &action)
          pending_actions << action
        end

        def wait_writable(io, &action)
          pending_actions << action
        end
      end
    end
  end
end
