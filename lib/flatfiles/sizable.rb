module FlatFiles
  module Sizable
    def self.extended(base)
      base.class_eval do
        class << self
          attr :size
        end

        @size = nil
      end
    end

    private

    # dsl method to set the record size
    def record_size(s)
      @size = s
    end
  end
end