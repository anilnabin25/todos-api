FactoryBot.define do
  factory :todo do
    title { FFaker::Lorem.word }
    created_by { FFaker::Number.number(10) }
  end
end
