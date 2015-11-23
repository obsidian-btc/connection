module Connection
  module Controls
    class Operation < Connection::Operation
      def self.build(io=nil, retries: nil, &block)
        io ||= StringIO.new
        block ||= ->{true}
        retries ||= 3

        instance = new block, io, retries
      end

      def wait_method
        :wait_readable
      end
    end

    def self.operation(*arguments, &block)
      operation = Operation.build *arguments, &block
      operation.()
    end
  end
end
