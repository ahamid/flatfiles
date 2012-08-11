require 'flatfiles/record_file'
require 'factory_girl'

module FlatFiles
  class Records
    MAX_RESULTS = 100

    def initialize(provider)
      @provider = provider
    end

    def generate(type, num)
      struct_class = record_class(type.to_sym)
      records = []
      num.times do
        records << FactoryGirl.build(type, impl_class: struct_class).pack
      end
      records
    end

    def get(resource, type, index)
      record_file(resource, type).record_at(index)
    end

    def all(resource, type)
      record_file(resource, type).records_array
    end

    def record_class(record_type)
      @provider[record_type.to_sym].record_class
    end

    def record_file(resource, record_type)
      RecordFile.new(resource, @provider[record_type.to_sym])
    end

  end
end