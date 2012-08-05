require_relative 'dsl-common'

module FlatFiles
  module RecordImpls

    class IndexableStruct < Struct
      # insert :index field
      def self.new(*args)
        name = []
        if args[0].is_a? String
          name = [ args.shift ]
        end
        super(*(name + [:index] + args))
      end

      # insert default :index value
      def initialize(*args)
        super(*([0] + args))
      end

      # why is this not available in Struct?
      def to_hash(clean = false)
        h = {}
        #h[:index] = index
        each_pair do |name, value|
          if !clean or !self.class.internal_field?(name)
            h[name] = value
          end
        end
        h
      end
    end
  end
end