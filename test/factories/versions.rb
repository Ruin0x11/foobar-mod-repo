FactoryBot.define do
  sequence :name do |n|
    "Mod #{n}"
  end

  sequence :number do |n|
    "0.#{n}.0"
  end

  factory :version do
    mod
    name
    number
    authors { ["Author1", "Author2"] }
    summary { "A summary for this mod." }
    licenses { ["MIT", "CC-BY"] }
    download_count { rand(0..1000) }
  end
end
