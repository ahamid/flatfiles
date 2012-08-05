module FlatFiles
  class RecordFile
    def initialize(file, record_class)
      @file = file
      @record_class = record_class
      @file_size = File.size(@file)
      if @file_size % @record_class.size != 0
        raise "File size is not a whole multiple of record size"
      end
      @num_records = @file_size / @record_class.size
    end

    def records(limit = nil)
      File.open(@file) do |file|
        @record_class.relation(file).to_a
      end
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
      File.open(@file) do |file|
        record_at_index(file, index)
      end
    end

    # returns records by array of indexes
    def records_at_indexes(indexes)
      results = []
      File.open(filename) do |file|
        for index in index_array.sort # sort for forward-only seeking
          #puts "Looking up index: #{index}"
          results << record_at_index(file, index)
        end
      end
      results
    end

    alias :'[]' :record_at

    private

    def record_at_index(file, index)
      # off-by-one: index/record numbers start at 1?
      # index 0 will be an error then...
      raise "Indexes start at 1" if index < 1
      idx = index - 1
      file.pos = idx * @record_class.size
      rec = @record_class.read(file)
      rec[:index] = index
      return rec
    end

    def self.parse_quoted_query(str)
      str.scan(/(\w+)|"(.*?)"/).flatten.compact
    end
  end
end