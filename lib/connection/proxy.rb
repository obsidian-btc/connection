module Connection
  class Proxy < Module
    attr_reader :io_method_names

    def initialize(*io_method_names)
      @io_method_names = io_method_names
    end

    def included(cls)
      cls.send :include, SocketWriter
      cls.send :include, PolicyAttribute

      io_method_modules.each do |mod|
        cls.send :include, mod
      end
    end

    def io_method_modules
      io_method_names.map do |method_name|
        const_name = method_name.to_s.capitalize
        IOMethods.const_get const_name
      end
    end

    module PolicyAttribute
      attr_writer :policy

      def policy
        @policy ||= Policy::Immediate
      end
    end

    module SocketWriter
      attr_writer :socket
    end
  end
end
