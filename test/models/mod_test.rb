# -*- coding: utf-8 -*-
require "test_helper"

class ModTest < ActiveSupport::TestCase
  context "with a mod" do
    setup do
      @mod = create(:mod, identifier: "test_mod")
    end
    subject { @mod }

    should have_many(:versions).dependent(:destroy)

    should allow_value("mod").for(:identifier)
    should allow_value("test1234").for(:identifier)
    should allow_value("test_mod").for(:identifier)
    should allow_value("a").for(:identifier)

    should_not allow_value("Mod").for(:identifier)
    should_not allow_value("_").for(:identifier)
    should_not allow_value("_mod").for(:identifier)
    should_not allow_value("test-mod").for(:identifier)
    should_not allow_value("test mod").for(:identifier)
    should_not allow_value("ほげ").for(:identifier)
    should_not allow_value("1234").for(:identifier)
    should_not allow_value("1mod").for(:identifier)
    should_not allow_value("base").for(:identifier)
    should_not allow_value("core").for(:identifier)
    should_not allow_value("script").for(:identifier)
    should_not allow_value("console").for(:identifier)
    should_not allow_value("").for(:identifier)

    should "return JSON" do
      version = create(:version, mod: @mod)
      dep     = create(:dependency, version: version)

      json = JSON.load(@mod.to_json)

      fields = %w[authors base_uri dependencies download_uri downloads
                  id licenses name summary updated_at version version_downloads]
      assert_equal fields.map(&:to_s).sort, json.keys.sort
      assert_equal @mod.identifier, json["id"]
      assert_equal @mod.name, json["name"]
      assert_equal @mod.downloads, json["downloads"]
      assert_equal @mod.versions.most_recent.number, json["version"]
      assert_equal @mod.versions.most_recent.download_count, json["version_downloads"]
      assert_equal @mod.versions.most_recent.authors, json["authors"]
      assert_equal @mod.versions.most_recent.summary, json["summary"]
      assert_equal @mod.versions.most_recent.licenses, json["licenses"]
      assert_date_equal @mod.updated_at, json["updated_at"]

      assert_equal JSON.load(dep.to_json), json["dependencies"].first
    end

    should "return the first creation date" do
      create(:version, mod: @mod, number: "0.3.0", created_at: 1.day.ago)
      create(:version, mod: @mod, number: "0.2.0", created_at: 2.days.ago)
      create(:version, mod: @mod, number: "0.1.0", created_at: 3.days.ago)

      assert_equal 3.days.ago.to_date, @mod.first_created_date.to_date
    end

    should "return latest version on the basis of version number" do
      version = create(:version, mod: @mod, number: "0.1.1")
      create(:version, mod: @mod, number: "0.0.9")
      create(:version, mod: @mod, number: "0.1.0", latest: true)

      assert_equal version, @mod.latest_version
    end

    should "recalculate the latest version on save" do
      create(:version, mod: @mod, number: "0.2.0")
      create(:version, mod: @mod, number: "0.1.0", latest: true)
      version = create(:version, mod: @mod, number: "0.3.0")

      assert_equal version, @mod.reload.latest_version
    end

    should "reorder versions properly" do
      version1 = create(:version, mod: @mod, number: "0.2.0")
      version2 = create(:version, mod: @mod, number: "0.1.0")
      version3 = create(:version, mod: @mod, number: "0.3.0")

      @mod.reorder_versions

      assert_equal 0, version3.reload.position
      assert_equal 1, version1.reload.position
      assert_equal 2, version2.reload.position

      latest_versions = Version.latest
      assert latest_versions.include?(version3)
      refute latest_versions.include?(version1)
      refute latest_versions.include?(version2)

      assert_equal version3, @mod.versions.most_recent
    end
  end
end
