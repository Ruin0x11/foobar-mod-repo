require 'test_helper'
require 'foobar_mod'

class DependencyTest < ActiveSupport::TestCase
  should belong_to :mod
  should belong_to :version

  context "with dependency" do
    setup do
      @version = create(:version)
      @dependency = build(:dependency, version: @version)
    end

    should "be valid with factory" do
      assert @dependency.valid?
    end

    should "return JSON" do
      @dependency.save
      json = JSON.load(@dependency.to_json)

      assert_equal %w[id requirements], json.keys.sort
      assert_equal @dependency.identifier, json["id"]
      assert_equal @dependency.requirements, json["requirements"]
    end
  end

  context "with a FoobarMod::Dependency" do
    context "that refers to a Mod that exists" do
      setup do
        @mod               = create(:mod)
        @requirements      = ['>= 0.0.0']
        @foobar_dependency = FoobarMod::Dependency.new(@mod.name, @requirements)
        @dependency        = create(:dependency, mod: @mod, foobar_dependency: @foobar_dependency)
      end

      should "create a Dependency referring to the existing Mod" do
        assert_equal @mod, @dependency.mod
        assert_equal @requirements[0].to_s, @dependency.requirements
      end
    end

    context "that refers to a Mod that exists and has multiple requirements" do
      setup do
        @mod               = create(:mod)
        @requirements      = ['< 1.0.0', '>= 0.0.0']
        @foobar_dependency = FoobarMod::Dependency.new(@mod.name, @requirements)
        @dependency        = create(:dependency, mod: @mod, foobar_dependency: @foobar_dependency)
      end

      should "create a Dependency referring to the existing Mod" do
        assert_equal @mod, @dependency.mod
        assert_equal @requirements.join(', '), @dependency.requirements
      end
    end

    context "that refers to a Mod that does not exist" do
      setup do
        @mod_identifier    = "hoge"
        @mod               = Mod.new(identifier: @mod_identifier)
        @foobar_dependency = FoobarMod::Dependency.new(@mod_identifier, "== 1.0.0")
      end

      should "not create a Dependency or a Mod" do
        dependency = Dependency.create(foobar_dependency: @foobar_dependency, version: @version)
        assert dependency.new_record?
        assert dependency.errors[:mod].present?
        assert_nil Mod.find_by(identifier: @mod_identifier)
      end
    end
  end

  context "without using FoobarMod::Dependency" do
    should "be invalid" do
      dependency = Dependency.create(foobar_dependency: ["piyo", ">= 0.2.0"])
      assert dependency.new_record?
      assert dependency.errors[:mod].present?
    end
  end

  context "with a FoobarMod::Dependency for with a blank name" do
    setup do
      @foobar_dependency = FoobarMod::Dependency.new("", "== 1.0.0")
    end

    should "not create a Dependency" do
      dependency = Dependency.create(foobar_dependency: @foobar_dependency)
      assert dependency.new_record?
      assert dependency.errors[:mod].present?
      assert_nil Mod.find_by(identifier: "")
    end
  end
end
