require 'spec_helper'

describe 'StructRecord' do
  let(:record_factory) do
    double("record_factory")
  end

  let(:field_names) { [ :active, :_honorific_len, :honorific, :_firstname_len, :firstname,
                        :_lastname_len, :lastname, :_email_len, :email, :unknown0,
                        :_street_len, :street, :_city_len, :city, :_state_len, :state, :_zipcode_len, :zipcode, :_areacode_len, :areacode,
                        :_home_phone_len, :home_phone, :_mobile_phone_len, :mobile_phone, :_note_len, :note, :salary, :companyid, :unknown1 ] }

  subject do
    rf = record_factory
    Class.new(FlatFiles::RecordImpls::DSL::StructRecord) do
      # explicitly set name since we are dynamically creating the class
      record_name "TestRecord"
      record_type rf
      include FlatFiles::Spec::DSL::EmployeeFields
    end
  end

  its(:size) { should eq(369) }
  its(:type) { should eq(record_factory) }
  its(:field_names) { should =~ field_names }

  it "should invoke factory" do
    new_record_args = [ subject.instance_variable_get(:@name) ] + field_names
    record_factory.should_receive(:new).with(*new_record_args) { |args| p args; FlatFiles::RecordImpls::IndexableStruct.new(args)}
    subject.new() # forces invocation of record type factory with field list
  end
end