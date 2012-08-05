module FlatFiles
  class RecordFileEnumerator < Enumerator
    attr_reader :reading
    def initialize(header, klass, resource, index_start = 0)
      @cache = []
      @reading = true
      super() do |y|
        resource.with do |io|
          index = index_start
          loop do
            offset = index - index_start
            tuple = @cache[offset]
            if tuple.nil?
              if @reading
                tuple = (@cache[offset] ||= read_tuple(index, header, klass, io))
              else
                raise StopIteration
              end
            end
            index += 1
            y << tuple
          end
        end
      end
    end

    protected

    def read_tuple(index, header, klass, io)
      record = begin
        klass.read(io)
      rescue EOFError
        # catch EOFError
      end
      if record == nil
        @reading = false
        raise StopIteration
      end
      make_tuple(header, index, record)
    end

    def make_tuple(header, index, record)
      raise NotImplementedError.new
    end
  end
end