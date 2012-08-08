require 'veritas'
require 'flatfiles/record_file_enumerator'

module FlatFiles
  module Veritas
    class TupleProvider
      def id
        raise NotImplementedError
      end

      def init_read_context
        nil
      end

      def read_record(index, header, io, context)
        raise NotImplementedError
      end

      def make_header
        raise NotImplementedError
      end

      def make_tuple(index, header, record)
        raise NotImplementedError
      end
    end

    class TupleProviderRelation < ::Veritas::Relation
      def initialize(tuple_provider, io)
        header = tuple_provider.make_header
        super(header, RecordFileEnumerator.new(header, tuple_provider, io))
      end
    end
  end
end