require 'spec_helper.rb'
require 'benchmark'
#.select { |k,v| k == :dsl_struct }
FlatFiles::ProviderRegistry.providers.values.each do |provider|
  describe "Company class #{provider[:company]}" do
    describe "parse Company" do
      subject do
        FlatFiles::Records.new(provider).get(open_file(TENK_COMPANIES), :company, 10)
      end

      {
        num_bytes: 425,
        index: 10,
        active: 'y',
        name: 'Nikolaus and Sons',
        founded: 722375301,
        slogan: "Front-line heuristic access",
        biz_id: 72110,
        contact: "elisabeth@labadie.com",
        contactid: 15824,
        unknown0: "XXXXXXXXXX",
        street: "Cormier Cliff",
        city: "South Urbanburgh",
        state: "HI",
        zipcode: "18083",
        areacode: "201",
        phone: "987-826-281",
        note: "ipsum consectetur atque facilis aspernatur ad quis necessitatibus incidunt quos eos esse sapiente qu",
        unknown1: "YYYYYYYYYYYYY"
      }.each do |field, value|
        its(field) { should == value }
        its("#{field.to_s}.length") { should == value.length } if value.is_a?(String)
      end

      it "is indexable" do
        subject[:index] = 1
        subject[:index].should == 1
        subject.index.should == 1
      end
    end
    
    describe "search Companies" do
      subject do
        FlatFiles::Records.new(provider).record_file(open_file(TENK_COMPANIES), :company).relation
      end
      
      it "should find companies by name" do
        results = nil
        @elapsed = Benchmark.realtime do
          results = subject.restrict { |rel| rel[:name].match(/Nikolaus/) }
          results.count.should == 48
        end
        p "Company search time for #{provider[:company]} " + @elapsed.to_s
        results.each do |c|
          c[:name].should =~ /Nikolaus/
        end
      end
    end
  end
end