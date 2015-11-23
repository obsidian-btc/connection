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

      def self.build(io, scheduler)
        instance = new io, scheduler
        ::Telemetry::Logger.configure instance
        instance
      end

      def call(sep_or_limit=nil, limit=nil)
        separator, limit = resolve_arguments sep_or_limit, limit
        output = ''

        Operation.read io, scheduler do |operation|
          next_char = io.read(1)
          next unless next_char
          operation.reset_retries

          output << next_char
          output if output.end_with?(separator) || output.bytesize == limit
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
