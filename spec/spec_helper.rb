require 'simplecov'
SimpleCov.start if ENV["COVERAGE"]

require 'benchmark_helper'
require 'factory_girl'
require 'test_data_setup.rb'

FactoryGirl.find_definitions

OPEN_FILES = {}

def open_file(name)
  content = OPEN_FILES[name]
  if content.nil?
    #file = File.open(name)
    #OPEN_FILES[name] = file

    #time = Benchmark.realtime do
      content = (OPEN_FILES[name] = File.read(name, File.size(name), mode: 'rb')).freeze
    #end
    #puts "Time to read file #{File.basename(name)}: #{time*1000} milliseconds"
  end
  FlatFiles::Util::BytesResource.new(name, content)
end

RSpec.configure do |c|
  c.color_enabled = true
  c.extend BenchmarkHelpers::ExampleGroupMethods
end