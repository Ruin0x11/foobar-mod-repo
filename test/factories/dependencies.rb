require "foobar_mod"

FactoryBot.define do
  factory :dependency do
    foobar_dependency { FoobarMod::Dependency.new(Mod.last.name, "1.0.0") }
    mod
    version
  end
end
