module FlatFiles
  class RecordFileEnumerator < Enumerator
    @@tuple_cache = {}

    attr_reader :reading
    def initialize(header, tuple_provider, resource, index_start = 0)
      @tuple_provider = tuple_provider
      @tuple_cache_id = tuple_provider.id + "/" + resource.id
      @cache = @@tuple_cache[@tuple_cache_id]
      if @cache
        @reading = false
      else
        @reading = true
        @cache = []
      end


      super() do |y|
        resource.with do |io|
          index = index_start
          context = tuple_provider.init_read_context
          loop do
            offset = index - index_start
            tuple = @cache[offset]
            if tuple.nil?
              if @reading
                tuple = (@cache[offset] ||= read_tuple(index, header, io, context))
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

    def read_tuple(index, header, io, context)
      record = begin
        @tuple_provider.read_record(index, header, io, context)
      rescue EOFError
        # catch EOFError
      end
      if record == nil
        @reading = false
        @@tuple_cache[@tuple_cache_id] = @cache
        raise StopIteration
      end
      @tuple_provider.make_tuple(index, header, record)
    end
  end
end