require 'bindata'
require 'veritas'
require 'flatfiles/sizable'
require 'flatfiles/record_file_enumerator'
require 'flatfiles/record_tuple'

module BinData
  SanitizedPrototype.class_eval do
    attr_reader :obj_class
  end
end        

module FlatFiles
  module RecordImpls
    module BinData
      class PascalStringField < ::BinData::Primitive
        mandatory_parameter :field_len

        uint8  :len,  :value => lambda { data.length }
        string :data, :length => :field_len, :trim_padding => true

        def get; self.data.value; end
        def set(v) self.data = v; end
      end

      class VeritasRecord < ::BinData::Record
        extend FlatFiles::Sizable

        def to_hash(*args)
          snapshot
        end

        def [](key)
          return @index if key == :index
          super
        end

        def []=(key, value)
          if key == :index
            @index = value
          else
            super
          end
        end

        alias :parse :read
        alias :pack :to_binary_s

        def self.relation(io)
          BinDataRelation.new(self, io)
        end
      end

      # Veritas support
      class BinDataEnumerator < RecordFileEnumerator
        protected
        def make_tuple(header, index, record)
          FlatFiles::RecordTuple.new(header, [ index ] + record.class.fields.collect { |f| record[f.name].value }, record)
        end
      end

      class BinDataRelation < Veritas::Relation
        def initialize(klass, io)
          header = BinDataRelation.header(klass)
          #record = klass.read(io)
          #row = BinDataTuple.new(header,BinDataTuple.make_values(header, 1, record))
          #super(header, [row]) #BinDataEnumerator.new(header, klass, io))
          super(header, BinDataEnumerator.new(header, klass, io))
        end

        protected

        def self.header(klass)
          fields = [[:index, Integer]]
          for field in klass.fields
            veritas_class = case field.prototype.obj_class.name
              when "BinData::String", "FlatFiles::RecordImpls::BinData::PascalStringField" then String
              when -> n { n.to_s =~ /int/ } then Integer
              else
                raise "Unknown type: " + field.prototype.obj_class.to_s
            end
            fields << [ field.name_as_sym, veritas_class ]
          end
          Veritas::Relation::Header.new(fields)
        end
      end
    end
  end
end