require_relative 'dsl-common'

module FlatFiles
  module Spec
    module DSL
      class CompanyStruct < FlatFiles::RecordImpls::DSL::StructRecord
        #record_size 415
        record_type FlatFiles::RecordImpls::IndexableStruct
        include CompanyFields
      end

      class EmployeeStruct < FlatFiles::RecordImpls::DSL::StructRecord
        #record_size 359
        record_type FlatFiles::RecordImpls::IndexableStruct
        include EmployeeFields
      end

      STRUCT_PROVIDER = {
        :company => CompanyStruct,
        :employee => EmployeeStruct
      }

      FlatFiles::ProviderRegistry.register(:dsl_struct, STRUCT_PROVIDER)
    end
  end
end