require 'spec_helper'

describe "Enumerator-based Relation" do
  class ArrayEnumerator < Enumerator
    def initialize(values)
      super() do |y|
        index = 0
        loop do
          raise StopIteration if index >= values.length
          row = [ index, values[index] ]
          index += 1
          y << row
        end
      end
    end
  end

  let(:a) { Axiom::Relation.new([[:index, Integer], [:name, String]], ArrayEnumerator.new([ "larry", "curly", "moe" ])) }
  let(:b) { Axiom::Relation.new([[:index, Integer], [:name, String]], ArrayEnumerator.new([ "red", "green", "blue" ])) }

  describe "relation a" do
    subject { a }
    its(:count) { should == 3 }
    it "should produce 3 tuples" do
      subject.to_a.should =~ [
        Axiom::Tuple.coerce(subject.header, [0, "larry"]),
        Axiom::Tuple.coerce(subject.header, [1, "curly"]),
        Axiom::Tuple.coerce(subject.header, [2, "moe"]),
      ]
    end
  end

  describe "relation b" do
    subject { b }
    its(:count) { should == 3 }
    it "should produce 3 tuples" do
      subject.to_a.should =~ [
        Axiom::Tuple.coerce(subject.header, [0, "red"]),
        Axiom::Tuple.coerce(subject.header, [1, "green"]),
        Axiom::Tuple.coerce(subject.header, [2, "blue"]),
      ]
    end
  end

  describe "restrict enumerator-based relations" do
    subject { a.restrict { |rel| rel[:index].eq(1) } }
    its(:count) { should == 1}
    it "should produce one tuple" do
      subject.to_a.should =~ [
        Axiom::Tuple.coerce(subject.header, [1, "curly"])
      ]
    end
    it "tuples should be index 1" do
      subject.each do |tuple|
        tuple[:index].should == 1
      end
    end
  end

  describe "natural-join enumerator-based relations" do
    let(:restricted) { a.restrict { |rel| rel[:index].eq(1) } }
    let(:joinee) { b.rename(name: :bname) }

    subject { restricted.join(joinee) }

    its(:count) { should == 1}
    it "should produce one tuple" do
      subject.to_a.should =~ [
        Axiom::Tuple.coerce(restricted.header | joinee.header, [1, "curly", "green"])
      ]
    end
  end

end
