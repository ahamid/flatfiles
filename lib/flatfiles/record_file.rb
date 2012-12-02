module FlatFiles
  class RecordFile
    def initialize(resource, tuple_provider)
      @resource = resource
      @tuple_provider = tuple_provider
      @file_size = @resource.size
      if @file_size % @tuple_provider.record_size != 0
        raise "File size is not a whole multiple of record size"
      end
      @num_records = @file_size / @tuple_provider.record_size
    end

    def relation
      @tuple_provider.relation(@resource)
    end

    def records(limit = nil)
      #relation.sort_by { |r| r.index }.take(limit).to_a
      if limit
        relation.tuples.first(limit) #.to_a
      else
        relation.to_a
      end
      #File.open(@file) do |file|
      #  @record_class.relation(file).to_a
      #end
      #Enumerator.new { |y|
      #  index = 0
      #  File.open(@file) do |file|
      #    loop {
      #      begin
      #        rec = @record_class.read(file)
      #        index += 1
      #        if rec
      #          rec[:index] = index
      #          y << rec
      #          break if limit and index >= limit
      #        end
      #      rescue EOFError
      #        raise StopIteration
      #      end
      #    }
      #  end
      #}
      #if records.length != num_records
      #  raise "Expected #{num_records} records but only parsed #{records.length}"
      #end
      #return records
    end

    def records_array(limit = nil)
      records(limit).to_a
    end

    # moves the file to the index position and reads a record
    def record_at(index)
      @resource.with do |io|
        record_at_index(io, index)
      end
    end

    # returns records by array of indexes
    def records_at_indexes(indexes)
      results = []
      @resource.with do |io|
        for index in index_array.sort # sort for forward-only seeking
          #puts "Looking up index: #{index}"
          results << record_at_index(io, index)
        end
      end
      results
    end

    alias :'[]' :record_at

    private

    def record_at_index(io, index)
      idx = index
      io.pos = idx * @tuple_provider.record_size
      rec = @tuple_provider.read_record(index, io, @tuple_provider.init_read_context)
      rec[:index] = index
      rec
    end

    def self.parse_quoted_query(str)
      str.scan(/(\w+)|"(.*?)"/).flatten.compact
    end
  end
end