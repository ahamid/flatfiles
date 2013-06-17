require 'axiom'
require 'flatfiles/sizable'
require 'flatfiles/record_file_enumerator'
require 'flatfiles/axiom/record_tuple'
require 'flatfiles/axiom/tuple_provider'

module FlatFiles
  module RecordImpls
    module DSL
      INTERNAL_FIELD_REGEX = /^_/

      class Field
        attr_accessor :type, :spec, :name, :data_lambda, :ignored

        def initialize(type, spec, name, data_lambda = nil, ignored = false)
          @type = type
          @spec = spec
          @name = name
          @data_lambda = data_lambda
          @ignored = ignored
        end

        def components
          self
        end

        def post_process(record)

        end
      end

      # Field subclass to support "pascal strings"
      # which are a pair of fields, length followed by string
      class PascalStringField < Field
        @@pascal_strings = []

        attr_accessor :limit

        # add a pascal string field (pair)
        # spec is the full spec (with preceding 'c' for length)
        # limit can be used to truncate generated value
        def initialize(type, spec, name = nil, data_lambda = nil, limit = nil)
          super(type, spec, name, data_lambda)
          @limit = limit
          len_field, string_field = PascalStringField.pascal_string_fields(@name)
          @len_field = Field.new(Integer, spec[0], len_field)
          # have to turn it back into a pascal string!
          # so the proc here actually returns the values
          # for both the len, and the string
          # this will get flattened into the values list
          # when packing the struct
          @string_field = Field.new(String, spec[1..-1], string_field, Proc.new {
            val = @data_lambda.call
            if @limit
              val.slice!(@limit..-1)
            end
            [ val.length, val ]
          })
          @@pascal_strings << self
        end

        def components
          [ @len_field, @string_field ]
        end

        # trim pascal field strings to specified length
        def post_process(record)
          len = record[@len_field.name] rescue nil
          if !len.nil? and len.is_a?(Fixnum)
            value = record[@string_field.name]
            value.slice!(len..-1)
            record[@string_field.name] = value # we can avoid reassignment assuming the value is a reference not a copy
          end
        end

        protected

        # returns the internal field name used for the
        # pascal length field
        def self.pascal_string_len_field(name)
          "_#{name.to_s}_len".to_sym
        end

        # returns the names of the two fields that comprise the pascal field
        def self.pascal_string_fields(name)
          [ pascal_string_len_field(name.to_sym), name.to_sym ]
        end
      end

      # A record prototype class which defines a DSL that allows subclasses to specify
      # record fields.  Subclasses statically set an internal record type factory on which new is invoked to produce
      # the concrete class which will be instantiated by the StructRecord new method.
      # The StructMixin module which introduces some helpers is mixed into the class the record
      # type factory produces.
      class StructRecord
        extend FlatFiles::Sizable

        class << self
          attr :type
          attr :lambdas
          attr :pascal_strings

          # define class vars in subclass
          def inherited(base)
            base.class_eval do
              @name = nil
              @unknown_inc = 0
              @fields = [ ]
              @fields_by_name = {}
              @field_components_by_name = {}
              @klass = nil

              record_name self.name.gsub("::","_") if self.name
            end
          end

          def new(*args)
            init_class
            record = @klass.new(*args)
            @fields.each do |f|
              f.post_process(record)
            end
            record
          end

          def read(file)
            bytes = file.read(self.size)
            raise EOFError if bytes.nil?
            return parse(bytes)
          end

          def parse(bytes)
            unpacked = bytes.unpack(self.field_spec_string)
            struct = new(*unpacked)
          end

          # pack the field values into an array, optionally generating missing values
          def pack(record, generate = false)
            vals = []
            # for each property, get the value
            # or generate one if there is a lambda/default value
            record.each_pair do |key, value|
              # if the value is nil and there is a lambda
              # generate it
              next if ignored?(key)

              if generate and value.nil?
                l = lambdas[key]
                if l
                  if l.is_a?(Proc)
                    # it's a proc. invoke it.
                    value = l.call if l.is_a?(Proc)
                  else
                    value = l
                  end
                end
              end
              # in general it would be inconsistent to flatten legitimate field values
              # (e.g. in case the value was actually nil or an array), however we know
              # that these are never legitimate field values so it must have been
              # explicitly set in order to support composite fields (or the user is crazy)
              if !value.nil?
                if value.is_a?(Array)
                  vals += value
                else
                  vals << value
                end
              end
            end

            packed = vals.pack(field_spec_string)
            raise "Packed struct size #{packed.length} does not match struct size: " + size.to_s if packed.length != size
            packed
          end

          def field_names
            @field_names ||= field_components.map { |c| c.name }
          end

          # called by struct class

          def ignored?(name)
            f = @field_components_by_name[name]
            !f || f.ignored
          end

          def field_components
            @field_components ||= @fields.map { |f| f.components }.flatten
          end

          protected

          def field_spec_string
             # create an array.pack field specifier string from all the field specs
             @field_spec_string ||= field_components.map { |c| c.spec }.join(' ')
          end

          private

          # DSL method to set the record name
          def record_name(n)
            @name = n
          end

          # # DSL method to set the record factory/type
          def record_type(t)
            @type = t
          end

          def pascal_string(spec, name = nil, data_lambda = nil, limit = nil)
            add_field PascalStringField.new(nil, spec, name || next_unknown_field_name, data_lambda, limit)
          end

          # adds a field specifier to the struct metadata
          def field(spec, name = nil, data_lambda = nil)
            add_field Field.new(String, spec, name || next_unknown_field_name, data_lambda)
          end

          def integer(spec, name = nil, data_lambda = nil)
            add_field Field.new(Integer, spec, name || next_unknown_field_name, data_lambda)
          end

          def ignore(spec, name = nil, data_lambda = nil)
            add_field Field.new(nil, "", name || next_unknown_field_name, data_lambda, true)
          end

          def add_field(field)
            raise "Duplicate field specified for record class #@name: #{field.name}" if @fields_by_name.has_key?(field.name)
            @fields << field
            @fields_by_name[field.name] = field
            [ field.components ].flatten.inject(@field_components_by_name) { |map, component| map[component.name] = component; map }
          end

          def init_class
            unless @klass
              # flatten fields to handle the case where a helper has contributed a series of fields
              # in an array
              klass_args = field_names
              # prepend the name if specified
              klass_args = [ @name ] + klass_args if @name

              template = self
              @klass = @type.new(*klass_args)
              @klass.class_eval do
                @template = template
                def self.template
                  @template
                end

                include StructMixin
              end
            end
          end

          # generate the next synthetic name for an anonymous field
          def next_unknown_field_name
            field_name = "unknown" + @unknown_inc.to_s
            @unknown_inc += 1
            field_name.to_sym
          end
        end
      end

      # methods mixed into the Struct class generated by the DSL
      # to wrap the fields
      module StructMixin
        def self.included(base)
          base.class_eval do
            def self.internal_field?(name)
              name.to_s =~ INTERNAL_FIELD_REGEX
            end
          end
        end

        # pack the field values into an array, optionally generating missing values
        def pack(generate = false)
          self.class.template.pack(self, generate)
        end

        def num_bytes
          self.class.template.size
        end
      end


      # an Axiom tuple provider implementation that derives attributes from Fields
      # and values from Hash lookups
      class HashRecordTupleProvider < FlatFiles::Axiom::BaseTupleProvider
        def read_record(index, io, context = nil)
          @record_class.read(io)
        end

        def make_tuple(index, record)
          FlatFiles::Axiom::RecordTuple.new(header, [ index ] + @field_names.map { |f| record[f] }, record)
        end

        def relation(resource)
          FlatFiles::Axiom::TupleProviderRelation.new(HashRecordTupleProvider.new(@record_class), resource)
        end

        protected

        def generate_header
          fields = record_class.field_components
          @field_names = fields.reject { |f| f.name =~ INTERNAL_FIELD_REGEX }.map { |f| f.name }
          @attributes = fields.reject { |k,v| k.name =~ INTERNAL_FIELD_REGEX }.map { |f| [ f.name, f.type ] }
          ::Axiom::Relation::Header.coerce([ [:index, Integer] ] + @attributes)
        end
      end

    end
  end
end
