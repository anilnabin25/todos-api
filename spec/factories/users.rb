FactoryBot.define do
  factory :user do
    name { FFaker::Name.name }
    email { 'user@example.com' }
    password_digest { 'password' }
  end
end
