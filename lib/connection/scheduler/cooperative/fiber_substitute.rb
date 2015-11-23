module Connection
  module Scheduler
    class Cooperative
      module FiberSubstitute
        module Substitute
          def self.build
            Namespace.new
          end
        end

        class Namespace
          attr_accessor :active
          attr_accessor :context_switches
          attr_accessor :yield_action

          def initialize
            @active = true
            @context_switches = 0
          end

          def active?
            active
          end

          def attach_yield_action(&block)
            self.yield_action = block
          end

          def context_switched?(count=nil)
            count ||= 1
            context_switches == count
          end

          def current
            Fiber.new self
          end

          def yield
            fail unless active?
            self.active = false
            yield_action.() if yield_action
          end
        end

        class Fiber
          attr_reader :fiber_substitute

          def initialize(fiber_substitute)
            @fiber_substitute = fiber_substitute
          end

          def resume
            fail if fiber_substitute.active?
            fiber_substitute.active = true
            fiber_substitute.context_switches += 1
          end
        end
      end
    end
  end
end
