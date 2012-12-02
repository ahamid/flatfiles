require_relative 'dsl-common'

module FlatFiles
  module Spec
    module DSL
      class CompanyStaticHash < FlatFiles::RecordImpls::DSL::StructRecord
        record_type FlatFiles::RecordImpls::StaticHashFactory
        include CompanyFields
      end

      class EmployeeStaticHash < FlatFiles::RecordImpls::DSL::StructRecord
        record_type FlatFiles::RecordImpls::StaticHashFactory
        include EmployeeFields
      end

      STATICHASH_PROVIDER = {
        :company => FlatFiles::RecordImpls::DSL::HashRecordTupleProvider.new(CompanyStaticHash),
        :employee => FlatFiles::RecordImpls::DSL::HashRecordTupleProvider.new(EmployeeStaticHash)
      }

      FlatFiles::ProviderRegistry.register(:dsl_statichash, STATICHASH_PROVIDER)
    end
  end
end