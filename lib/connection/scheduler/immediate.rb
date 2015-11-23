module Connection
  module Scheduler
    class Immediate
      def self.instance
        @instance ||= new
      end

      def wait_readable(io)
      end

      def wait_writable(io)
      end
    end
  end
end
