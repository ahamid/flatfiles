require 'axiom'

module FlatFiles
  module Axiom
    # re-open class to add optional record field
    # we need to use Axiom::Tuple class
    # as class is considered when testing equality
    module RecordTupleMixin
    #  def initialize(header, values, record = nil)
    #    super(header, values)
    #    @record = record
    #  end

      def self.included(base)
        original_initialize = base.instance_method(:initialize)
        base.class_eval do
          define_method(:initialize) do |header, values, record = nil|
            original_initialize.bind(self).call(header, values)
            @record = record
          end
        end
      end

      def to_hash(clean = false)
        header.inject({}) { |hash, a| hash[a.name] = self[a.name]; hash }
      end
    end

    class RecordTuple < ::Axiom::Tuple
      def self.new(header, values, record = nil)
        #@record = record
        #super(header, values)
        #::Axiom::Tuple.new(header, values, record)
        ::Axiom::Tuple.new(header, values)
      end
    end
  end
end

#class Axiom::Tuple
#  include FlatFiles::Axiom::RecordTupleMixin
#end

class Axiom::Relation
  # hack tuples to be public so we can explicitly
  # read N values at a time
  public :tuples
end
