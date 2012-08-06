module FlatFiles
  module Util
    class IOResource
      attr_reader :mode

      def initialize(mode = 'r')
        @mode = mode
      end

      def id; raise NotImplementedError end
      def with(&block); raise NotImplementedError end
      def size; raise NotImplementedError end
    end

    class FileResource < IOResource
      attr_reader :file
      def initialize(file, mode = 'r')
        @file = file
        super(mode)
      end

      alias :file :id

      def with(&block)
        File.open(@file, @mode, &block)
      end

      def size
        File.size(@file)
      end
    end

    class BytesResource < IOResource
      attr_reader :content
      attr_reader :id

      def initialize(id, content, mode = 'r')
        @id = id
        @content = content
        super(mode)
      end

      def with(&block)
        StringIO.open(@content, @mode, &block)
      end

      def size
        @content.length
      end
    end
  end
end