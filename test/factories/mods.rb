FactoryBot.define do
  sequence :identifier do |n|
    "mod#{n}"
  end

  factory :mod do
    identifier
    user
  end
end
