require_relative 'dsl-common'

module FlatFiles
  module RecordImpls

    class StaticHashFactory
      @@CLASS_CACHE = Hash.new do |hash, field_names|
        hash[field_names] = Class.new(StaticHash) do
          class << self; attr :field_names end
          @field_names = *field_names

          # define accessors for all fields
          ([ :index ] + field_names).each do |n|
            define_method n do
              self[n]
            end
            define_method :"#{n}=" do |val|
              self[n] = val
            end
          end
        end
      end

      def self.new(*field_names)
        field_names.shift # first arg is class name
        # prepend index to auto-define the accessor for sythetic field
        @@CLASS_CACHE[field_names]
      end
    end

    class StaticHash < Hash
      def initialize(*args)
        self.class.field_names.each_with_index do |f, i|
          break unless args.length > i
          self[f] = args[i]
        end
      end

      def to_hash(clean = false)
        return self if !clean
        h = {}
        each_pair do |key, value|
          h[key] = value if !clean or !self.class.internal_field?(key)
        end
        return h
      end

      def each_pair(&block)
        for name in self.class.field_names
          block.call([name, self[name]])
        end
      end
    end
  end
end