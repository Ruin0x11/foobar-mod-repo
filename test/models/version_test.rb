require 'test_helper'

class VersionTest < ActiveSupport::TestCase
  context "with a mod" do
    setup do
      @mod = create(:mod)
    end

    should "return JSON" do
      @version = create(:version, mod: @mod)

      json = JSON.load(@version.to_json)

      fields = %w[authors created_at summary download_count number
                  licenses]
      assert_equal fields.map(&:to_s).sort, json.keys.sort
      assert_equal @version.authors, json["authors"]
      assert_equal @version.summary, json["summary"]
      assert_equal @version.download_count, json["download_count"]
      assert_equal @version.number, json["number"]
      assert_equal @version.licenses, json["licenses"]
      assert_date_equal @version.created_at, json["created_at"]
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
