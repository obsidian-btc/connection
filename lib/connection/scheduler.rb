module Connection
  module Scheduler
    def self.configure(receiver)
      instance = Blocking.build
      receiver.scheduler = instance
      instance
    end

    class Substitute < Immediate
      attr_accessor :context_switches

      def initialize
        @context_switches = 0
      end

      def self.build
        Substitute.new
      end

      def context_switched?
        context_switches > 0
      end

      def wait_readable(io)
        self.context_switches += 1
      end

      def wait_writable(io)
        self.context_switches += 1
      end
    end
  end
end
