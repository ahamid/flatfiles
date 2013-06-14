require 'bindata'
require 'axiom'
require 'flatfiles/sizable'
require 'flatfiles/record_file_enumerator'
require 'flatfiles/axiom/record_tuple'
require 'flatfiles/axiom/tuple_provider'

module BinData
  SanitizedPrototype.class_eval do
    attr_reader :obj_class
  end
end        

module FlatFiles
  module RecordImpls
    module BinData
      # reopen to expose field_objs to avoid lookups
      class ::BinData::Struct
        def field_objs
          @field_objs
        end
      end


      class PascalStringField < ::BinData::Primitive
        mandatory_parameter :field_len

        uint8  :len,  :value => lambda { data.length }
        string :data, :length => :field_len, :trim_padding => true

        def get
          #self.data.value
          @struct["data"].value
        end
        def set(v) self.data = v; end
      end

      class AxiomRecord < ::BinData::Record
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
      end

      class BinDataTupleProvider < FlatFiles::Axiom::BaseTupleProvider

        def init_read_context
          @record_class.new
        end

        def read_record(index, io, record_template = init_read_context)
          record_template.clear
          record_template.read(io)
        end

        def make_tuple(index, record)
          #values = [ index ] + record.class.fields.collect { |f| record[f.name].value }
          values = [ index ] + record.field_objs.collect { |f| f.value }
          FlatFiles::Axiom::RecordTuple.new(header, values, record)
        end

        def relation(resource)
          FlatFiles::Axiom::TupleProviderRelation.new(BinDataTupleProvider.new(@record_class), resource)
        end

        protected

        def generate_header
          fields = [[:index, Integer]]
          for field in @record_class.fields
            axiom_class = case field.prototype.obj_class.name
              when "BinData::String", "FlatFiles::RecordImpls::BinData::PascalStringField" then String
              when -> n { n.to_s =~ /int/ } then Integer
              else
                raise "Unknown type: " + field.prototype.obj_class.to_s
            end
            fields << [ field.name_as_sym, axiom_class ]
          end
          ::Axiom::Relation::Header.new(fields)
        end
      end
    end
  end
end
