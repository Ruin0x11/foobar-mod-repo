# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'factory_bot_rails'

User.create(handle: "ruin", email: "ruin@elonafoobar.com", password: "12345678")

10.times do
  FactoryBot.create(:user)
end

20.times do
  FactoryBot.create(:mod)
end

Mod.all.each do |mod|
  10.times do
    mod.versions.create(FactoryBot.attributes_for(:version)) do |version|
      version.save!
      2.times do
        version.dependencies.create(FactoryBot.attributes_for(:dependency))
      end
    end
  end
end

