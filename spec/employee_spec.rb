require 'spec_helper.rb'

require 'benchmark'

FlatFiles::ProviderRegistry.providers.values.each do |provider|
  describe "Employee class #{provider[:employee]}" do
    describe "parse Employee" do
      subject do
        FlatFiles::Records.new(provider).get(open_file(FORTYK_EMPLOYEES), :employee, 10)
      end

      {
        num_bytes: 369,
        index: 10,
        active: 'y',
        honorific: 'Miss',
        firstname: 'Herminio',
        lastname: 'Langosh',
        email: "malcolm@berge.biz",
        unknown0: "XXXXXXXXXX",
        street: "Martin Dam",
        city: "Croninton",
        state: "Ne",
        zipcode: "57506",
        areacode: "575",
        home_phone: "592-748-655",
        mobile_phone: "461-402-104",
        note: "veniam adipisci earum consequatur dolores quidem dolor eaque cumque quod quae ratione aut cupiditate",
        salary: 34334,
        companyid: 9806,
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
    
    describe "employee relation" do
      subject do
        FlatFiles::Records.new(provider).record_file(open_file(ONE_EMPLOYEE), :employee).relation
      end

      its(:count) { should == 1 }

      it "should return the employee tuple" do
        subject.to_a.first[:index].should == 0
      end
    end

    describe "search Employee" do
      subject do
        FlatFiles::Records.new(provider).record_file(open_file(FORTYK_EMPLOYEES), :employee).relation
      end

      it "should find companies by companyid" do
        results = nil
        @elapsed = Benchmark.realtime do
          results = subject.restrict { |rel| rel[:companyid].eq(9806) }
          results.count.should == 4
        end
        p "Employee companyid search time for #{provider[:employee]} " + @elapsed.to_s
        results.each do |r|
          r[:companyid].should == 9806
        end
      end

      it "should find employee by first name" do
        results = nil
        @elapsed = Benchmark.realtime do
          results = subject.restrict { |rel| rel[:firstname].match(/Herminio/) }
          results.count.should == 20
        end
        p "Employee first name search time for #{provider[:employee]} " + @elapsed.to_s
        results.each do |r|
          r[:firstname].should =~ /Herminio/
        end
      end
    end
  end
end