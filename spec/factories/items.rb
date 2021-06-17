FactoryBot.define do
  factory :item do
    name { FFaker::Name.name }
    done { false }
    todo { nil }
  end
end
