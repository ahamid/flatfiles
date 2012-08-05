require 'spec_helper'

require 'flatfiles/record_file_enumerator'

describe FlatFiles::RecordFileEnumerator do
  let(:record_class) { double("record class") }
  let(:header) { double("header") }
  let(:io) { double("io") }
  let(:resource) {
    res = double("resource")
    res.stub(:with) { |&block| block.yield(io) }
    res
  }
  subject { FlatFiles::RecordFileEnumerator.new(header, record_class, resource) }

  it "make_tuple throws NotImplemented" do
    record_class.should_receive(:read).with(io) { double("record") }
    expect { subject.next }.to raise_error(NotImplementedError)
  end

  describe "with tuple data" do
    let(:tuple_values) { [ [0, "red"], [1, "green" ], [ 2, "blue" ] ]}
    before do
      record_class.stub(:read).and_return(*(tuple_values + [nil]))
      subject.stub(:make_tuple) { |header, index, record| record }

      # file is only traversed forward once!
      record_class.should_receive(:read).exactly(4).times.with(io)
      subject.should_receive(:make_tuple).exactly(3).times.with(header, instance_of(Fixnum), instance_of(Array))
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
      subject.next.should == tuple_values[1]

      subject.inject(0) { |sum,x| sum + 1 }.should == 3

      subject.to_a.should == tuple_values
    end
  end
end