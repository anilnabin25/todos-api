FactoryBot.define do
  factory :todo do
    title { FFaker::Lorem.word }
    # created_by { Faker::Number.number(10) }
    created_by { FFaker::Random.rand(1000000000..9999999999) }
  end
end
