require_relative 'dsl-common'

module FlatFiles
  module Spec
    module DSL
      class CompanyLightweightStruct < FlatFiles::RecordImpls::DSL::StructRecord
        #record_size 415
        record_type FlatFiles::RecordImpls::LightweightStructFactory
        include CompanyFields
      end

      class EmployeeLightweightStruct < FlatFiles::RecordImpls::DSL::StructRecord
        #record_size 359
        record_type FlatFiles::RecordImpls::LightweightStructFactory
        include EmployeeFields
      end

      LWSTRUCT_PROVIDER = {
        :company => FlatFiles::RecordImpls::DSL::HashRecordTupleProvider.new(CompanyLightweightStruct),
        :employee => FlatFiles::RecordImpls::DSL::HashRecordTupleProvider.new(EmployeeLightweightStruct)
      }

      FlatFiles::ProviderRegistry.register(:dsl_lwstruct, LWSTRUCT_PROVIDER)
    end
  end
end