require_relative 'dsl-common'

module FlatFiles
  module Spec
    module DSL
      class CompanyStruct < FlatFiles::RecordImpls::DSL::StructRecord
        record_type FlatFiles::RecordImpls::IndexableStruct
        include CompanyFields
      end

      class EmployeeStruct < FlatFiles::RecordImpls::DSL::StructRecord
        record_type FlatFiles::RecordImpls::IndexableStruct
        include EmployeeFields
      end

      STRUCT_PROVIDER = {
        :company => FlatFiles::RecordImpls::DSL::HashRecordTupleProvider.new(CompanyStruct),
        :employee => FlatFiles::RecordImpls::DSL::HashRecordTupleProvider.new(EmployeeStruct)
      }

      FlatFiles::ProviderRegistry.register(:dsl_struct, STRUCT_PROVIDER)
    end
  end
end