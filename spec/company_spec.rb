require 'spec_helper.rb'
require 'benchmark'
#.select { |k,v| k == :dsl_struct }
FlatFiles::ProviderRegistry.providers.values.each do |provider|
  describe "Company class #{provider[:company].record_class}" do
    describe "parse Company" do
      subject do
        FlatFiles::Records.new(provider).get(open_file(TENK_COMPANIES), :company, 10)
      end

      {
        num_bytes: 426,
        index: 10,
        active: 'y',
        name: 'Schmidt Inc',
        founded: 496003513,
        slogan: "Intuitive solution-oriented archive",
        biz_id: 44277,
        contact: "krista@hermann.info",
        contactid: 23176,
        unknown0: "XXXXXXXXXX",
        street: "Murray Motorway",
        city: "Dakotaside",
        state: "MN",
        zipcode: "98115",
        areacode: "887",
        phone: "177-460-9814",
        note: "similique omnis saepe rerum quisquam minima est omnis ut assumenda qui inventore iusto autem dolorem",
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
          results = subject.restrict { |rel| rel[:name].match(/Schmidt/) }
          results.count.should == 46
        end
        puts "Company search time for #{provider[:company].record_class} " + @elapsed.to_s
        results.each do |c|
          c[:name].should =~ /Schmidt/
        end
      end
    end
  end
end
