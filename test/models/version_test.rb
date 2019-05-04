require 'test_helper'

class VersionTest < ActiveSupport::TestCase
  context "with a mod" do
    setup do
      @mod = create(:mod)
    end

    should "not allow duplicate versions" do
      @version = build(:version, mod: @mod, number: "1.0.0")
      @dup_version = @version.dup
      @number_version = build(:version, mod: @mod, number: "2.0.0")

      assert @version.save
      assert @number_version.save
      refute @dup_version.valid?
    end

    should "be able to find dependencies" do
      @dependency = create(:mod)
      @version = build(:version, mod: @mod, number: "1.0.0")
      @version.dependencies << create(:dependency, version: @version, mod: @dependency)
      refute Version.first.dependencies.empty?
    end

    should "sort dependencies alphabetically" do
      @version = build(:version, mod: @mod, number: "1.0.0")

      @first_dependency_by_alpha = create(:mod, identifier: 'acts_as_indexed')
      @second_dependency_by_alpha = create(:mod, identifier: 'friendly_id')
      @third_dependency_by_alpha = create(:mod, identifier: 'refinerycms')

      @version.dependencies << create(:dependency,
        version: @version,
        mod: @second_dependency_by_alpha)
      @version.dependencies << create(:dependency,
        version: @version,
        mod: @third_dependency_by_alpha)
      @version.dependencies << create(:dependency,
        version: @version,
        mod: @first_dependency_by_alpha)

      assert @first_dependency_by_alpha.identifier, @version.dependencies.first.identifier
      assert @second_dependency_by_alpha.identifier, @version.dependencies.second.identifier
      assert @third_dependency_by_alpha.identifier, @version.dependencies.last.identifier
    end
  end
end
