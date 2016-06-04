FactoryGirl.define do
  factory :order do
    association :origin, factory: :location
    association :destination, factory: :location
    number { "#{Faker::Number.number(9)}:#{Faker::Number.number(2)}:#{Faker::Number.number(2)}" }
    volume { Faker::Number.decimal(2) }
    quantity { Faker::Number.between(0, 20) }
    delivery_date { Faker::Date.forward(7) }
  end
end
