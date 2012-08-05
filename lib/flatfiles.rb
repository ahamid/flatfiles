require 'flatfiles/providers'
require 'flatfiles/records'
require 'flatfiles/util/resource'
Dir[File.expand_path(File.dirname(__FILE__) + '/flatfiles/record_impls/*.rb')].each {|f| require f }