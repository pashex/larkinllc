FactoryGirl.define do
  factory :load do
    delivery_date { Faker::Date.forward(1) }
    shift { 'morning' }
  end
end
