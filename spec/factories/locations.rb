FactoryGirl.define do
  factory :location do
    name { Faker::Name.name }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    country { Faker::Address.country_code }
    zip { Faker::Address.zip }
    phone { Faker::PhoneNumber.phone_number }
  end
end
