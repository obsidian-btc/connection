module Connection
  class Client
    class Readline
      attr_reader :io
      attr_reader :scheduler

      dependency :logger, ::Telemetry::Logger

      def initialize(io, scheduler)
        @io = io
        @scheduler = scheduler
      end

      def self.build(io, scheduler=nil)
        scheduler ||= Scheduler::Blocking.build

        instance = new io, scheduler
        ::Telemetry::Logger.configure instance
        instance
      end

      def call(*arguments)
        Operation.read io, scheduler do |operation, attempt|
          char = io.read_nonblock 1
          io.ungetc char
          io.readline *arguments
        end
      end

      def resolve_arguments(sep_or_limit, limit)
        if limit
          separator = sep_or_limit
        elsif sep_or_limit.is_a? Integer
          limit = sep_or_limit
        else
          separator = sep_or_limit
        end

        limit ||= Float::INFINITY
        separator ||= $/

        return separator, limit
      end
    end
  end
end
