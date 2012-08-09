require 'veritas'
require 'flatfiles/record_file_enumerator'

module FlatFiles
  module Veritas
    class TupleProvider
      def id
        raise NotImplementedError
      end

      def record_size
        raise NotImplementedError
      end

      def init_read_context
        nil
      end

      def read_record(index, io, context)
        raise NotImplementedError
      end

      def header
        raise NotImplementedError
      end

      def make_tuple(index, record)
        raise NotImplementedError
      end

      def relation(resource)
        raise NotImplementedError
      end
    end

    class TupleProviderRelation < ::Veritas::Relation
      def initialize(tuple_provider, resource)
        header = tuple_provider.header
        super(header, RecordFileEnumerator.new(tuple_provider, resource))
      end
    end
  end
end