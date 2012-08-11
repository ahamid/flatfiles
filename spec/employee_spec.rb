require 'spec_helper.rb'

require 'benchmark'

FlatFiles::ProviderRegistry.providers.values.each do |provider|
  describe "Employee class #{provider[:employee].record_class}" do
    describe "parse Employee" do
      subject do
        FlatFiles::Records.new(provider).get(open_file(FORTYK_EMPLOYEES), :employee, 10)
      end

      {
        num_bytes: 371,
        index: 10,
        active: 'y',
        honorific: 'Mrs.',
        firstname: 'Christine',
        lastname: 'Bauch',
        email: "lucinda_oberbrunner@reynolds.biz",
        unknown0: "XXXXXXXXXX",
        street: "Parisian Shoals",
        city: "Christaland",
        state: "Co",
        zipcode: "56671-2155",
        areacode: "604",
        home_phone: "344-283-2703",
        mobile_phone: "439-544-9120",
        note: "aut velit adipisci beatae earum voluptas veniam fugit minus cum explicabo ipsam eius incidunt omnis",
        salary: 36871,
        companyid: 9730,
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

      it "should find employees by companyid" do
        results = nil
        @elapsed = Benchmark.realtime do
          results = subject.restrict { |rel| rel[:companyid].eq(9806) }
          results.count.should == 4
        end
        p "Employee companyid search time for #{provider[:employee].record_class} " + @elapsed.to_s
        results.each do |r|
          r[:companyid].should == 9806
        end
      end

      it "should find employee by first name" do
        results = nil
        @elapsed = Benchmark.realtime do
          results = subject.restrict { |rel| rel[:firstname].match(/Christine/) }
          results.count.should == 17
        end
        p "Employee first name search time for #{provider[:employee].record_class} " + @elapsed.to_s
        results.each do |r|
          r[:firstname].should =~ /Christine/
        end
      end
    end
  end
end