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
    sha256 { "tdQEXD9Gb6kf4sxqvnkjKhpXzfEE96JucW4KHieJ33g=" }

    trait :with_file do
      after(:create) do |version, evaluator|
        mod_file = Rails.root.join("test", "mods", "test-0.0.0.zip").open
        pusher = Pusher.new(version.mod.user, mod_file)
        pusher.process
        if pusher.mod.new_record?
          pusher.mod.save!
        end
      end
    end
  end
end
