FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :handle do |n|
    "handle#{n}"
  end

  factory :user do
    email
    handle
    password { "password12345" }
  end
end
