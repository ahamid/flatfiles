require_relative 'dsl-common'

module FlatFiles
  module RecordImpls

    class LightweightStructFactory
      @@CLASS_CACHE = Hash.new do |hash, field_names|
        hash[field_names] = Class.new(LightweightStruct) do
          class << self; attr :field_names end
          @field_names = *field_names

          def initialize(*values)
            @field_hash = {}
            self.class.field_names.zip(values).each do |key, value|
              @field_hash[key] = (value || nil)
            end
            super(@field_hash)
          end
        end
      end

      def self.new(*field_names)
        field_names.shift # first arg is class name
        @@CLASS_CACHE[field_names]
      end
    end

    class LightweightStruct < OpenStruct
      attr_reader :table

      def to_hash(clean = false)
        return table if !clean
        h = {}
        table.each_pair do |key, value|
          if !clean or !self.class.internal_field?(key)
            h[key] = table[key]
          end
        end
        h
      end

      def [](key)
        table[key.to_sym]
      end

      def []=(key, value)
        table[key.to_sym] = value
      end

      def each_pair(&block)
        for field in self.class.field_names
          block.call(field, table[field])
        end
      end
    end
  end
end