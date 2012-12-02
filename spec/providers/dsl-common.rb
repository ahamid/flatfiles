require 'flatfiles'
require 'faker'

module FlatFiles
  module Spec
    module DSL
      module CompanyFields
        def self.included(base)
          base.class_eval do
            record_size 426

            field         'a',     :active,    'y'
            pascal_string 'ca50',  :name,      Faker::Company.method(:name)
            integer       'N',     :founded,   lambda { rand(Time.now_to_i) }
            pascal_string 'ca75',  :slogan,    Faker::Company.method(:catch_phrase)
            integer       'N',     :biz_id,    lambda { rand(100000) }
            pascal_string 'ca50',  :contact,   Faker::Internet.method(:email)
            integer       'v',     :contactid, 0
            field         'a10',   nil,        'X' * 10
            pascal_string 'ca50',  :street,    Faker::Address.method(:street_name)
            pascal_string 'ca30',  :city,      Faker::Address.method(:city)
            pascal_string 'ca2',   :state,     Faker::Address.method(:state_abbr)
            pascal_string 'ca10',  :zipcode,   Faker::Address.method(:zip_code)
            pascal_string 'ca3',   :areacode,  lambda { Faker::Base.numerify('###') }
            pascal_string 'ca12',  :phone,     lambda { Faker::Base.numerify('###-###-####') }
            pascal_string 'ca100', :note,      lambda { Faker::Lorem.words(15).join(' ') }
            field         'a13',   nil,        'X' * 13
          end
        end
      end
      
      module EmployeeFields
        def self.included(base)
          base.class_eval do
            record_size 371

            field         'a',     :active,       'y'
            pascal_string 'ca10',  :honorific,    Faker::Name.method(:prefix)
            pascal_string 'ca25',  :firstname,    Faker::Name.method(:first_name)
            pascal_string 'ca25',  :lastname,     Faker::Name.method(:last_name)
            pascal_string 'ca50',  :email,        Faker::Internet.method(:email)
            field         'a10',   nil,           'X' * 10
            pascal_string 'ca50',  :street,       Faker::Address.method(:street_name)
            pascal_string 'ca30',  :city,         Faker::Address.method(:city)
            pascal_string 'ca2',   :state,        Faker::Address.method(:state_abbr)
            pascal_string 'ca10',  :zipcode,      Faker::Address.method(:zip_code)
            pascal_string 'ca3',   :areacode,     lambda { Faker::Base.numerify('###') }
            pascal_string 'ca12',  :home_phone,   lambda { Faker::Base.numerify('###-###-####') }
            pascal_string 'ca12',  :mobile_phone, lambda { Faker::Base.numerify('###-###-####') }
            pascal_string 'ca100', :note,         lambda { Faker::Lorem.words(15).join(' ') }
            integer       'N',     :salary,       lambda { Random.rand(1000..100000) }
            integer       'v',     :companyid,    0
            field         'a13',   nil,           'X' * 13
          end
        end
      end
    end
  end
end