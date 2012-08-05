require_relative '../providers/bindata'

FactoryGirl.define do
  factory :company, :class => FlatFiles::Spec::BinData::Company do |o|
    o.active    'y'
    o.name      { Faker::Company.name }
    o.founded   { rand(Time.now.to_i) }
    o.slogan    { Faker::Company.catch_phrase }
    o.biz_id    { rand(100000) }
    o.contact   { Faker::Internet.email }
    o.contactid 0
    o.unknown0  'X' * 10
    o.street    { Faker::Address.street_name }
    o.city      { Faker::Address.city }
    o.state     { Faker::Address.us_state_abbr }
    o.zipcode   { Faker::Address.zip_code }
    o.areacode  { Faker::Base.numerify('###') }
    o.phone     { Faker::Base.numerify('###-###-###') }
    o.note      { Faker::Lorem.words(15).join(' ') }
    o.unknown1  'Y' * 13
  end

  factory :employee, :class => FlatFiles::Spec::BinData::Employee do |o|
    o.active       'y'
    o.honorific    { Faker::Name.prefix }
    o.firstname    { Faker::Name.first_name }
    o.lastname     { Faker::Name.last_name }
    o.email        { Faker::Internet.email }
    o.unknown0     'X' * 10
    o.street       { Faker::Address.street_name }
    o.city         { Faker::Address.city }
    o.state        { Faker::Address.us_state }
    o.zipcode      { Faker::Address.zip_code }
    o.areacode     { Faker::Base.numerify('###') }
    o.home_phone   { Faker::Base.numerify('###-###-###') }
    o.mobile_phone { Faker::Base.numerify('###-###-###') }
    o.note         { Faker::Lorem.words(15).join(' ') }
    o.salary       { Random.rand(1000..100000) }
    o.companyid    0
    o.unknown1     'Y' * 13
  end
end