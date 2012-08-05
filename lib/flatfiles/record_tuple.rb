# re-open class to add optional record field
# we need to use Veritas::Tuple class
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

class Veritas::Tuple
  include RecordTupleMixin
end

module FlatFiles
  class RecordTuple < Veritas::Tuple
    def self.new(header, values, record = nil)
      #@record = record
      #super(header, values)
      Veritas::Tuple.new(header, values, record)
    end
  end
end