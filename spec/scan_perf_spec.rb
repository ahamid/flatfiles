require 'spec_helper'

FlatFiles::ProviderRegistry.providers.each do |key, provider|
  describe "Full scan performance #{key}" do
    describe "Employee records" do
      subject { FlatFiles::RecordFile.new(FlatFiles::Util::FileResource.new(FORTYK_EMPLOYEES), provider[:employee]) }
      benchmark "loads every Employee record #{key}" do
        subject.relation.to_a
      end
    end

    #describe "Company records" do
    #  subject { FlatFiles::RecordFile.new(FlatFiles::Util::FileResource.new(TENK_COMPANIES), provider[:company]) }
    #  benchmark "loads every Company record #{key}" do
    #    subject.relation.to_a
    #  end
    #end
  end
end