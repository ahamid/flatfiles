require 'ruby-prof'
require 'benchmark'

module BenchmarkHelpers
  PROFILE_OUTPUT_DIR = "profiling"
  def self.safe_filename(name)
    name.gsub(" ", "_")
  end

  def self.example_output_target_file!(example)
    dir = File.join([ PROFILE_OUTPUT_DIR ] + example.example_group.ancestors.map { |a| BenchmarkHelpers.safe_filename(a.description) })
    FileUtils.mkdir_p(dir)
    File.expand_path(BenchmarkHelpers.safe_filename(example.description), dir)
  end

  def self.profile_example(example, options = {}, &block)
    # kcachegrind output default
    options = { profile_printer: RubyProf::CallTreePrinter }.merge(options)
    RubyProf.start
    begin
      example.example_group_instance.instance_eval(&block)
    ensure
      result = RubyProf.stop
    end
    printer = options[:profile_printer].new(result)
    filename = BenchmarkHelpers.example_output_target_file!(example)
    file = File.new(filename + ".dat", 'w')
    printer.print(file, {})
  end

  def self.benchmark_example(example, options = {}, &block)
    Benchmark.bm(options[:label_width] || example.description.length) do |bm|
      bm.report(example.description) do
        example.example_group_instance.instance_eval(&block)
      end
    end
  end

  module ExampleGroupMethods
    def profile(description, options = {}, &block)
      benchmark_profile(description, { profile: true }.merge(options), &block)
    end

    def benchmark(description, options = {}, &block)
      benchmark_profile(description, { benchmark: true }.merge(options), &block)
    end

    def benchprof(description, options = {}, &block)
      benchmark_profile(description, { benchmark: true, profile: true }.merge(options), &block)
    end

    def benchmark_profile(description, options, &block)
      options = { label_width: 50, perf: true }.merge(options)
      proc = block
      if options[:benchmark]
        proc = Proc.new { BenchmarkHelpers.benchmark_example(example, options, &block) }
      end
      if options[:profile]
        inner_proc = proc
        proc = Proc.new { BenchmarkHelpers.profile_example(example, options, &inner_proc) }
      end
      it description, options, &proc
    end
  end
end
