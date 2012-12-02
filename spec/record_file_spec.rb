require 'spec_helper'

FlatFiles::ProviderRegistry.providers.each do |key, provider|
  describe "RecordFile with #{key}" do
    
    benchmark "parse individual record", label_width: 50 do
      some_arbitrary_record = 1234
      recordfile = FlatFiles::RecordFile.new(open_file(FORTYK_EMPLOYEES), provider[:employee])
      employee = recordfile[some_arbitrary_record]
      employee.index.should == 1234

      employee.firstname.should == "Rosina"
      employee.lastname.should == "Volkman"
      employee.companyid.should == 2297
    end
    
    benchmark "parse all records", label_width: 50 do
      recordfile = FlatFiles::RecordFile.new(open_file(FORTYK_EMPLOYEES), provider[:employee])
      records = recordfile.records_array #records_array(40000)

      records.length.should == 40000
      records.each do |rec|
        rec[:companyid].should be
        #rec.companyid.should be_a(Fixnum) # bindata has its own types :(
        rec[:companyid].should be >= 0
        rec[:companyid].should be < 10000
      end
    end

    benchmark "find employee", label_width: 50 do
      recordfile = FlatFiles::RecordFile.new(open_file(ONE_EMPLOYEE), provider[:employee])
      records = recordfile.relation.restrict { |r| r.lastname.match(/Bergstrom/) } # =~ doesn't work?
      records.should be
      records.count.should == 1
      records.to_a[0][:firstname].should == "Rod"
    end
  end
end