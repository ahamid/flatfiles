require 'spec_helper'

FlatFiles::ProviderRegistry.providers.each do |key, provider|
  describe "RecordFile with #{key}" do
    
    benchprof "parse individual record", label_width: 50 do
      some_arbitrary_record = 1234
      recordfile = FlatFiles::RecordFile.new(open_file(FORTYK_EMPLOYEES), provider[:employee])
      employee = recordfile[some_arbitrary_record]
      employee.index.should == 1234
      employee.companyid.should == 6506
      employee.firstname.should == "Omari"
      employee.lastname.should == "Davis"

    end
    
    benchprof "parse all records", label_width: 50 do
      recordfile = FlatFiles::RecordFile.new(open_file(FORTYK_EMPLOYEES), provider[:employee])
      records = recordfile.records_array(100)
      records.length.should == 100
      records.each do |rec|
        rec.companyid.should be
        #rec.companyid.should be_a(Fixnum) # bindata has its own types :(
        rec.companyid.should be > 0
        rec.companyid.should be < 10000
      end
    end
    
    benchprof "find employee", label_width: 50 do
      recordfile = FlatFiles::RecordFile.new(open_file(ONE_EMPLOYEE), provider[:employee])
      records = recordfile.relation.restrict { |r| r.firstname =~ /Iure/ }
      records.should be
      records.length.should == 1
    end
  end
end