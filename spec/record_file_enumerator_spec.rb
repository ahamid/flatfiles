require 'spec_helper'

require 'flatfiles/record_file_enumerator'

describe FlatFiles::RecordFileEnumerator do
  let(:io) { double("io") }
  let(:resource) {
    res = double("resource")
    res.stub(:with) { |&block| block.yield(io) }
    res.stub(:id) { 'ResourceId' }
    res
  }
  let(:init_ctx) { double("initial context") }
  let(:tuple_provider) {
    tp = FlatFiles::Veritas::TupleProvider.new
    tp.stub(:id) { 'TupleProviderId' }
    tp.stub(:init_read_context) { init_ctx }
    tp
  }

  subject {
    FlatFiles::RecordFileEnumerator.reset_tuple_cache
    FlatFiles::RecordFileEnumerator.new(tuple_provider, resource)
  }

  it "make_tuple throws NotImplemented" do
    record = double("record")
    tuple = double("tuple")

    tuple_provider.should_receive(:init_read_context)
    tuple_provider.should_receive(:read_record).with(0, io, init_ctx) { record }
    expect { subject.next }.to raise_error(NotImplementedError)

    tuple_provider.should_receive(:init_read_context)
    tuple_provider.should_receive(:read_record).with(0, io, init_ctx) { record }
    tuple_provider.should_receive(:make_tuple).with(0, record) { tuple }
    subject.next.should == tuple
  end

  describe "with tuple data" do
    let(:tuple_values) { [ [0, "red"], [1, "green" ], [ 2, "blue" ] ]}

    before(:each) do
      tuple_provider.stub(:read_record) { |index, io, context| tuple_values[index] }
      tuple_provider.stub(:make_tuple) { |index, record| record }

      # file is only traversed forward once!
      tuple_provider.should_receive(:read_record).exactly(4).times
      tuple_provider.should_receive(:make_tuple).exactly(3).times.with(instance_of(Fixnum), instance_of(Array))
    end

    describe "read all items once" do
      its(:count) { should == 3 }
      its(:to_a) { should == tuple_values }

      it "next should yield tuples" do
        subject.next.should == tuple_values[0]
        subject.next.should == tuple_values[1]
        subject.next.should == tuple_values[2]
        expect { subject.next }.to raise_error(StopIteration)
      end
    end

    it "should be repeatably iterable" do
      subject.next.should == tuple_values[0]

      subject.reading.should be_true

      subject.inject(0) { |sum,x| sum + 1 }.should == 3

      subject.reading.should be_false

      # apparently .next uses a distinct pass from each/inject methods
      # so .next resumes at pos 1
      subject.next.should == tuple_values[1]

      subject.inject(0) { |sum,x| sum + 1 }.should == 3

      subject.to_a.should == tuple_values
    end
  end
end