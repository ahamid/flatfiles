require 'simplecov'
SimpleCov.start if ENV["COVERAGE"]

require 'benchmark_helper'
require 'factory_girl'
require 'flatfiles'
require 'flatfiles/util/resource'

Dir[File.expand_path(File.dirname(__FILE__) + '/providers/*.rb')].each {|f| require f }

FactoryGirl.find_definitions

ONE_EMPLOYEE = File.expand_path("./test-data/1-employee.dat", File.dirname(__FILE__))
ONE_COMPANY = File.expand_path("./test-data/1-company.dat", File.dirname(__FILE__))
FORTYK_EMPLOYEES = File.expand_path("./test-data/40000-employees.dat", File.dirname(__FILE__))
TENK_COMPANIES = File.expand_path("./test-data/10000-companies.dat", File.dirname(__FILE__))

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