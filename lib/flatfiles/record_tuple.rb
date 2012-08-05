# re-open class to add optional record field
# we need to use Veritas::Tuple class
# as class is considered when testing equality
class Veritas::Tuple
  def initialize(header, values, record = nil)
    super(header, values)
    @record = record
  end
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