FactoryGirl.define do
  factory :dynamic_impl, class: Object do
    # impl_class option must be passed in order for impl class to be dynamically selected
    ignore do
      impl_class nil
    end
    initialize_with { impl_class.new }
  end

  factory :company, parent: :dynamic_impl do #:class => FlatFiles::Spec::BinData::Company
    active    'y'
    name      { Faker::Company.name }
    founded   { rand(Time.now.to_i) }
    slogan    { Faker::Company.catch_phrase }
    biz_id    { rand(100000) }
    contact   { Faker::Internet.email }
    contactid 0
    unknown0  'X' * 10
    street    { Faker::Address.street_name }
    city      { Faker::Address.city }
    state     { Faker::Address.us_state_abbr }
    zipcode   { Faker::Address.zip_code }
    areacode  { Faker::Base.numerify('###') }
    phone     { Faker::Base.numerify('###-###-####') }
    note      { Faker::Lorem.words(15).join(' ') }
    unknown1  'Y' * 13
  end

  factory :employee, parent: :dynamic_impl do |o| #:class => FlatFiles::Spec::BinData::Employee
    active       'y'
    honorific    { Faker::Name.prefix }
    firstname    { Faker::Name.first_name }
    lastname     { Faker::Name.last_name }
    email        { Faker::Internet.email }
    unknown0     'X' * 10
    street       { Faker::Address.street_name }
    city         { Faker::Address.city }
    state        { Faker::Address.us_state }
    zipcode      { Faker::Address.zip_code }
    areacode     { Faker::Base.numerify('###') }
    home_phone   { Faker::Base.numerify('###-###-####') }
    mobile_phone { Faker::Base.numerify('###-###-####') }
    note         { Faker::Lorem.words(15).join(' ') }
    salary       { Random.rand(1000..100000) }
    companyid    0
    unknown1     'Y' * 13
  end
end