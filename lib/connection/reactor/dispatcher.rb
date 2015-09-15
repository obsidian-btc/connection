module Connection
  class Reactor
    class Dispatcher
      def self.build
        instance = new
        Telemetry::Logger.configure instance
        instance
      end

      attr_reader :pending_reads
      attr_reader :pending_writes
      attr_reader :timers

      dependency :logger, Telemetry::Logger

      def initialize
        @pending_reads = {}
        @pending_writes = {}
        @timers = []
      end

      def check_timers
        timers.delete_if do |timer|
          timer.check
        end
      end

      def dispatch_read(socket)
        handler = pending_reads.delete socket
        handler.(socket)
      end

      def dispatch_write(socket)
        handler = pending_writes.delete socket
        handler.(socket)
      end

      def pending_sockets
        reads = pending_reads.keys
        writes = pending_writes.keys
        return reads, writes
      end

      def register_read(io_resource, &handler)
        pending_reads[io_resource] = handler
      end

      def register_write(io_resource, &handler)
        pending_writes[io_resource] = handler
      end

      def register_timer(milliseconds, &handler)
        timer = Timer.build milliseconds, handler
        timers << timer
      end

      class Timer
        attr_reader :duration_ms
        attr_reader :handler
        attr_reader :t0

        dependency :clock, Time

        def initialize(duration_ms, handler)
          @duration_ms = duration_ms
          @handler = handler
        end

        def self.build(duration_ms, handler)
          instance = new duration_ms, handler
          instance.clock = Time
          instance.start
          instance
        end

        def check
          if expired?
            handler.()
            true
          else
            false
          end
        end

        def duration
          @duration ||= Rational(duration_ms, 1000)
        end

        def expired?
          delta = t1 - t0
          delta > duration
        end

        def start
          @t0 = clock.now
        end

        def t1
          clock.now
        end
      end
    end
  end
end
