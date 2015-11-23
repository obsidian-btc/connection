module Connection
  module Controls
    class ExampleReactorLoop
      attr_reader :reads
      attr_reader :fibers
      attr_reader :writes

      def initialize
        @fibers = []
        @reads = {}
        @writes = {}
      end

      def add_fiber(&block)
        fiber = Fiber.new &block
        fibers << fiber
      end

      def start
        return_values = []

        while fibers.any?
          fiber, return_value = swap

          if fiber.alive?
            fibers.push fiber
          else
            return_values.push return_value
          end
        end

        return_values
      end

      def wait_readable(io, &callback)
        reads[io] = callback
      end

      def wait_writable(io, &callback)
        writes[io] = callback
      end

      def swap
        active_fiber = fibers.shift
        return_value = active_fiber.resume
        return active_fiber, return_value
      end
    end

    def self.example_reactor_loop
      reactor_loop = ExampleReactorLoop.new
      scheduler = Connection::Scheduler::Cooperative.build reactor_loop
      return reactor_loop, scheduler
    end
  end
end
