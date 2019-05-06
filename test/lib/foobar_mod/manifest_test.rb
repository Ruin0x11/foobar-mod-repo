# coding: utf-8
# frozen_string_literal: true
require "test_helper"
require "foobar_mod/package"

class FoobarMod::TestManifest < ActiveSupport::TestCase
  def setup
    super

    @manifest = quick_manifest 'a', '0.1.0' do |m|
      m.name = "A Mod"
      m.summary = 'π'
      m.license = "MIT"
    end
  end

  def test_full_identifier
    assert_equal @manifest.full_identifier, "a-0.1.0"
  end

  def test_base_dir
    assert_nil @manifest.base_dir

    @manifest.loaded_from = "dood/mod.hcl"
    assert_equal File.expand_path("dood"), @manifest.base_dir

    @manifest.loaded_from = "dood/a-0.1.0.zip"
    assert_equal File.expand_path("dood/a-0.1.0"), @manifest.base_dir
  end

  def test_manifest_file
    @manifest.loaded_from = "a-0.1.0/mod.hcl"
    assert_equal File.expand_path("a-0.1.0/mod.hcl"), @manifest.manifest_file
  end

  def test_zip_file
    assert_nil @manifest.zip_file

    @manifest.loaded_from = "dood/mod.hcl"
    assert_equal File.expand_path("a-0.1.0.zip"), @manifest.zip_file

    @manifest.loaded_from = "dood/a-0.1.0.zip"
    assert_equal File.expand_path("dood/a-0.1.0.zip"), @manifest.zip_file
  end

  def test_version
    assert_equal FoobarMod::Version.new('0.1.0'), @manifest.version
  end

  def test_license
    assert_equal 'MIT', @manifest.license
  end

  def test_licenses
    assert_equal ['MIT'], @manifest.licenses
  end

  def test_name
    assert_equal 'A Mod', @manifest.name
  end

  def test_identifier
    assert_equal 'a', @manifest.identifier
  end

  def test_summary
    assert_equal 'π', @manifest.summary
  end

  def test_version_change_reset_full_identifier
    orig_full_identifier = @manifest.full_identifier

    @manifest.version = "2"

    refute_equal orig_full_identifier, @manifest.full_identifier
  end

  def test_version_change_reset_zip_file
    @manifest.loaded_from = "dood/mod.hcl"
    orig_zip_file = @manifest.zip_file

    @manifest.version = "2"

    refute_equal orig_zip_file, @manifest.zip_file
  end

  def test_loaded_from_change_reset_zip_file
    orig_zip_file = @manifest.zip_file

    @manifest.loaded_from = "dood/test-0.1.0.zip"

    refute_equal orig_zip_file, @manifest.zip_file
  end

  def test_version_full_name
    @manifest.version = "2"

    assert_equal "a-2.0.0", @manifest.full_identifier
  end

  def test_from_file
    assert_equal false, @manifest.from_file?

    @manifest.loaded_from = "dood"
    assert_equal false, @manifest.from_file?

    @manifest.loaded_from = "test-0.1.0.zip"
    assert_equal true, @manifest.from_file?

    @manifest.loaded_from = "dood/mod.hcl"
    assert_equal true, @manifest.from_file?
  end

  def test_from_manifest_file
    assert_equal false, @manifest.from_manifest_file?

    @manifest.loaded_from = "dood"
    assert_equal false, @manifest.from_manifest_file?

    @manifest.loaded_from = "test-0.1.0.zip"
    assert_equal false, @manifest.from_manifest_file?

    @manifest.loaded_from = "dood/mod.hcl"
    assert_equal true, @manifest.from_manifest_file?
  end

  def test_from_zip
    assert_equal false, @manifest.from_zip?

    @manifest.loaded_from = "dood"
    assert_equal false, @manifest.from_zip?

    @manifest.loaded_from = "test-0.1.0.zip"
    assert_equal true, @manifest.from_zip?

    @manifest.loaded_from = "dood/mod.hcl"
    assert_equal false, @manifest.from_zip?
  end

end
