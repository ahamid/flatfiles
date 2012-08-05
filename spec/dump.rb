#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require 'optparse'
require 'ostruct'
require 'factory_girl'
require 'flatfiles'

require 'json'

require 'optparse'
require 'ostruct'
require 'pp'

# require all test providers
Dir[File.expand_path(File.dirname(__FILE__) + '/providers/*.rb')].each {|f| require f }
FactoryGirl.find_definitions

def print_records(records, json=false, pretty=false)
  if json
    puts ({ "records" => records }).to_json(pretty ? JSON::PRETTY_STATE_PROTOTYPE : {})
  else
    records.each { |r| pretty ? pp(r) : $stdout.write(r) }
    $stdout.flush
  end
end

types = FlatFiles::ProviderRegistry.record_types.to_a.join(", ")

options = OpenStruct.new
# whether to output JSON
# defaults on for parse and off for generate
options.json = nil
options.pretty = nil
options.count = false
options.provider_type = :bindata

opts = OptionParser.new do |opts|
  opts.banner="Usage: records.rb [parse {#{types}} {file} | generate {#{types}} {num} | search {#{types}} {file} {criteria}]"
  opts.on("-r", "--provider provider", "Record schema provider") do |r|
    options.provider_type = r.to_sym
  end
  opts.on("-c", "--count", "Just print a count of matches") do |c|
    options.count = c
  end
  opts.on("-p", "--[no-]pretty", "Generate pretty json") do |p|
    options.json = true
    options.pretty = p
  end
  opts.on("-j", "--[no-]json", "Generate json") do |j|
    options.json = j
  end
end

if ARGV.length < 3
  puts opts.help
  exit 1
end

command = ARGV[0]
ARGV.shift

opts.parse!(ARGV)
provider = FlatFiles::ProviderRegistry[options.provider_type]

type = ARGV[0].to_sym

case command
  when "parse" then
    options.json = true if options.json.nil?
    options.pretty = true if options.pretty.nil?

    filename = ARGV[1]

    results = FlatFiles::Records.new(provider).all(filename, type)
    if options.count
      puts "Results: #{results.length}"
    else
      records = []
      results.each do |record|
        if options.json
          #records << record.normalize_pascal_strings.to_hash(true)
          records << record.to_hash(true)
        else
          records << record.pack
        end
      end

      print_records(records, options.json, options.pretty)
    end

  when "generate" then
    options.json = false if options.json.nil?
    options.pretty = false if options.pretty.nil?

    num = ARGV[1].to_i

    results = FlatFiles::Records.new(provider).generate(type, num)
    if options.count
      puts "Results: #{results.length}"
    else
      records = []
      results.each do |record_string|
        if options.json
          records << provider[type].parse(record_string).normalize_pascal_strings.to_hash(true)
        else
          records << record_string
        end
      end

      print_records(records, options.json, options.pretty)
    end

  when "generate-test-data" then
    # FIXME: ya, option handling sucks on this command
    num_companies = ARGV[0].to_i
    num_employees = ARGV[1].to_i

    company_file = ARGV[2]
    employee_file = ARGV[3]

    puts "Generating #{num_companies} companies into #{company_file}"
    puts "Generating #{num_employees} employees into #{employee_file}"

    # generate some companies. contactids are all 0
    companies = FlatFiles::Records.new(provider).generate(:company, num_companies).map { |rec| provider[:company].parse(rec) }
    # generate some employees. companyids are all o
    employees = FlatFiles::Records.new(provider).generate(:employee, num_employees).map { |rec| provider[:employee].parse(rec) }

    # set random company for all employees
    company_employees = {}
    File.open(employee_file, "w") do |file|
      employees.each_with_index do |rec, i|
        idx = rand(companies.length)
        rec.companyid = idx

        # add the employee index to company list
        e = (company_employees[idx] ||= [])
        e << i

        # write out employee
        file.write(rec.pack)
      end
    end
    # now set random contact for each company
    File.open(company_file, "w") do |file|
      # write out all the companies
      companies.each_with_index do |rec, i|
        e = company_employees[i]
        rec.contactid = e.sample
        file.write(rec.pack)
      end
    end

  when "search" then
    options.json = false if options.json.nil?
    options.pretty = true if options.pretty.nil?

    filename = ARGV[1]
    criteria = ARGV[2]

    records = FlatFiles::Records.new(provider).search(filename, type, criteria)

    if options.count
      puts "Results: #{records.length}"
    else
      print_records(records, options.json, options.pretty)
    end

  else
    puts "Unknown command: #{command}"
end
