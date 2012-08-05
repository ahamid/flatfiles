require 'set'

module FlatFiles
  class ProviderRegistry
    @@providers = {}

    def self.register(symbol, provider)
      @@providers[symbol] = provider
    end

    def self.providers
      @@providers.keys
    end

    def self.[](key)
      @@providers[key].dup.freeze
    end

    def self.record_types
      @@providers.inject(Set.new) { |types, (key, provider) | types.merge(provider.keys) }
    end
  end
end