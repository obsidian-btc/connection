module Connection
  class Client
    class Readline
      attr_reader :scheduler

      dependency :logger, ::Telemetry::Logger

      def initialize(scheduler)
        @scheduler = scheduler
      end

      def self.build(scheduler=nil)
        instance = new scheduler
        ::Telemetry::Logger.configure instance
        instance
      end

      def call(io, *arguments)
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
