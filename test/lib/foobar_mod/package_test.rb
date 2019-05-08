# coding: utf-8
# frozen_string_literal: true
require "test_helper"
require "foobar_mod/package"

class FoobarMod::TestPackage < ActiveSupport::TestCase
  def setup
    super

    @manifest = write_mod 'a', "0.1.0" do |m|
      m.summary = 'π'
    end

    build_mod @manifest

    @mod = @manifest.zip_file
  end

  def test_build_time_source_date_epoch
    epoch = ENV["SOURCE_DATE_EPOCH"]
    ENV["SOURCE_DATE_EPOCH"] = "123456789"

    manifest = FoobarMod::Manifest.new 'build', '1', 'mod.hcl'
    manifest.summary = 'build'
    manifest.authors = 'build'

    package = FoobarMod::Package.new manifest.file_name

    assert_equal Time.at(ENV["SOURCE_DATE_EPOCH"].to_i).utc, package.build_time
  ensure
    ENV["SOURCE_DATE_EPOCH"] = epoch
  end

  def test_add_files
    manifest = FoobarMod::Manifest.new 'build', '1', 'build/mod.hcl'

    FileUtils.mkdir_p "build/empty"

    File.open 'build/code.lua',  'w' do |io|
      io.write '-- build/code.lua'
    end

    File.open 'build/extra.lua', 'w' do |io|
      io.write '-- build/extra.lua'
    end

    package = FoobarMod::Package.new 'bogus.gem'
    package.manifest = manifest

    zip = util_zip do |zip_io|
      package.add_files zip_io
    end

    zip.rewind

    files = []

    Zip::InputStream.open(zip) do |zip_io|
      while entry = zip_io.get_next_entry
        files << entry.name
      end
    end

    assert_equal %w[code.lua extra.lua], files.sort
  end

  def test_add_files_symlink
    manifest = FoobarMod::Manifest.new 'build', '1', 'build/mod.hcl'

    FileUtils.mkdir_p 'build'

    File.open 'build/code.lua',  'w' do |io|
      io.write '-- build/code.lua'
    end

    File.symlink('code.lua', 'build/code_sym.lua')
    File.symlink('../build/code.lua', 'build/code_sym2.lua')

    p manifest.base_dir

    package = FoobarMod::Package.new "bogus.zip"
    package.manifest = manifest

    zip = util_zip do |zip_io|
      package.add_files zip_io
    end

    files, symlinks = [], []

    Zip::InputStream.open(zip) do |zip_io|
      while entry = zip_io.get_next_entry
        if entry.symlink?
          symlinks << entry.name
        else
          files << entry.name
        end
      end
    end

    assert_equal %w[code.lua], files
    assert_equal [], symlinks
  end

  def test_build
    manifest = FoobarMod::Manifest.new 'build', '1', 'build/mod.hcl'
    manifest.name = "Build"
    manifest.summary = 'build'
    manifest.authors = 'build'

    FileUtils.mkdir_p "build"

    File.open 'build/init.lua', 'w' do |io|
      io.write '-- build/init.lua'
    end

    File.open 'build/mod.hcl', 'w' do |io|
      io.write 'mod {}'
    end

    package = FoobarMod::Package.new manifest.file_name
    package.manifest = manifest

    package.build

    assert_path_exists manifest.file_name

    reader = FoobarMod::Package.new manifest.file_name
    assert_equal manifest, reader.manifest

    assert_equal %w[src/code.lua], reader.files
  end

  def test_build_invalid
    manifest = FoobarMod::Manifest.new 'build', '1', 'build/mod.hcl'

    package = FoobarMod::Package.new manifest.file_name
    package.manifest = manifest

    e = assert_raises FoobarMod::InvalidManifestException do
      package.build
    end

    assert_equal 'missing value for attribute name', e.message
  end

  def test_files
    package = FoobarMod::Package.new @mod

    assert_equal %w[init.lua mod.hcl], package.files
  end

  def test_load_manifest
    entry = OpenStruct.new(manifest: @manifest)
    def entry.get_input_stream() StringIO.new manifest.to_hcl end

    package = FoobarMod::Package.new 'nonexistent.zip'

    manifest = package.load_manifest entry

    assert_equal @manifest, manifest
  end

  def test_verify
    package = FoobarMod::Package.new @mod

    package.verify

    assert_equal @manifest, package.manifest
    assert_equal %w[], package.files.sort
  end

  def test_verify_empty
    FileUtils.touch 'empty.zip'

    package = FoobarMod::Package.new 'empty.zip'

    e = assert_raises FoobarMod::Package::FormatError do
      package.verify
    end

    assert_equal "Missing required file 'mod.hcl' in empty.zip", e.message
  end

  def test_verify_nonexistent
    package = FoobarMod::Package.new 'nonexistent.zip'

    e = assert_raises FoobarMod::Package::FormatError do
      package.verify
    end

    assert_match %r%^No such file or directory%, e.message
    assert_match %r%nonexistent.zip$%,           e.message
  end

  def test_verify_truncate
    File.open 'bad.zip', 'wb' do |io|
      io.write File.read(@mod, 64) # don't care about newlines
    end

    package = FoobarMod::Package.new 'bad.zip'

    e = assert_raises FoobarMod::Package::FormatError do
      package.verify
    end

    assert_equal "Missing required file 'mod.hcl' in bad.zip", e.message
  end

  def test_manifest
    package = FoobarMod::Package.new @mod

    assert_equal @manifest, package.manifest
  end

  def test_manifest_from_io
    # This functionality is used by rubygems.org to extract manifest data from an
    # uploaded gem before it is written to storage.
    io = StringIO.new FoobarMod.read_binary @mod
    package = FoobarMod::Package.new io

    assert_equal @manifest, package.manifest
  end

  def test_manifest_from_io_raises_gem_error_for_io_not_at_start
    io = StringIO.new FoobarMod.read_binary @mod
    io.read(1)
    assert_raises(FoobarMod::Package::Error) do
      FoobarMod::Package.new io
    end
  end

  def test_prevents_loading_of_large_manifest
    io = util_zip do |zip|
      zip.put_next_entry("mod.hcl")
      zip.write("a" * 1024 * 100)
    end

    package = FoobarMod::Package.new io

    e = assert_raises(FoobarMod::Package::Error) do
      package.verify
    end

    assert_equal 'Mod manifest size is too large', e.message
  end

  def util_zip
    zip_io = StringIO.new

    Zip::OutputStream.write_buffer(zip_io) do |zip|
      yield zip
    end

    zip_io.rewind

    zip_io
  end
end
