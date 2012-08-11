require 'flatfiles'

module FlatFiles
  module Spec
    module BinData
      class Company < FlatFiles::RecordImpls::BinData::VeritasRecord
        record_size 426

        attr_accessor :index

        string              :active,   :length => 1
        pascal_string_field :name,     :field_len => 50
        uint32be            :founded
        pascal_string_field :slogan,   :field_len => 75
        uint32be            :biz_id
        pascal_string_field :contact,  :field_len => 50
        uint16le            :contactid
        string              :unknown0, :length => 10
        pascal_string_field :street,   :field_len => 50
        pascal_string_field :city,     :field_len => 30
        pascal_string_field :state,    :field_len => 2
        pascal_string_field :zipcode,  :field_len => 10
        pascal_string_field :areacode, :field_len => 3
        pascal_string_field :phone,    :field_len => 12
        pascal_string_field :note,     :field_len => 100
        string              :unknown1, :length => 13
      end

      class Employee < FlatFiles::RecordImpls::BinData::VeritasRecord
        record_size 371

        attr_accessor :index

        string              :active,       :length => 1
        pascal_string_field :honorific,    :field_len => 10
        pascal_string_field :firstname,    :field_len => 25
        pascal_string_field :lastname,     :field_len => 25
        pascal_string_field :email,        :field_len => 50
        string              :unknown0,     :length => 10
        pascal_string_field :street,       :field_len => 50
        pascal_string_field :city,         :field_len => 30
        pascal_string_field :state,        :field_len => 2
        pascal_string_field :zipcode,      :field_len => 10
        pascal_string_field :areacode,     :field_len => 3
        pascal_string_field :home_phone,   :field_len => 12
        pascal_string_field :mobile_phone, :field_len => 12
        pascal_string_field :note,         :field_len => 100
        uint32be            :salary
        uint16le            :companyid
        string              :unknown1,     :length => 13
      end

      PROVIDER = {
        :company => FlatFiles::RecordImpls::BinData::BinDataTupleProvider.new(Company),
        :employee => FlatFiles::RecordImpls::BinData::BinDataTupleProvider.new(Employee)
      }

      FlatFiles::ProviderRegistry.register(:bindata, PROVIDER)
    end
  end
end