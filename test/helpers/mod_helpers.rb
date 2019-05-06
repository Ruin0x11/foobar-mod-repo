module ModHelpers
  def mod_file(name = "test-0.0.0.zip")
    Rails.root.join("test", "mods", name.to_s).open
  end

  ##
  # Creates a FoobarMod::Manifest with a minimum of extra work.
  # +identifier+ and +version+ are the mod's identifier and version,
  # author, homepage, and summary are defaulted. The manifest is
  # yielded for customization.

  def quick_manifest(identifier, version="0.1.0", deps = nil)
    raise "deps or block, not both" if deps and block_given?

    require "foobar_mod/manifest"

    manifest = FoobarMod::Manifest.new do |s|
      s.identifier  = identifier
      s.version     = version
      s.name        = "A Mod"
      s.author      = "A User"
      # s.homepage    = "http://example.com"
      s.summary     = "this is a summary"

      yield(s) if block_given?
    end

    manifest
  end

  def write_mod(identifier, version="0.1.0", deps = nil)
    manifest = quick_manifest(identifier, version, deps) do |s|
      yield(s) if block_given?
    end

    manifest.loaded_from = File.join @tempdir, identifier, "mod.hcl"
    p manifest.from_manifest_file?
    p manifest.from_zip?

    FileUtils.mkdir_p manifest.base_dir
    write_file manifest.manifest_file do |io|
      io.write manifest.to_hcl
    end
    write_file File.join(manifest.base_dir, "init.lua")

    manifest
  end

  def write_file(path)
    path = File.join @modhome, path unless Pathname.new(path).absolute?
    dir = File.dirname path
    FileUtils.mkdir_p dir unless File.directory? dir

    File.open path, 'wb' do |io|
      yield io if block_given?
    end

    path
  end

  def build_mod(manifest)
    puts "Write to  #{manifest.zip_file}"
    FoobarMod::Package.build manifest
  end

  def remove_mod(spec)
    FileUtils.rm_rf manifest.zip_file
    FileUtils.rm_rf manifest.manifest_file
  end
end
