# frozen_string_literal: true

##
# Based on Gem::Package from RubyGems.

require "zip"
require "zip_file_generator"

class FoobarMod::Package

  REQUIRED_FILES = ["mod.hcl", "init.lua"]

  attr_accessor :build_time # :nodoc:

  ##
  # Sets the FoobarMod::Manifest to use to build this package.

  attr_writer :manifest

  class Error < Gem::Exception; end

  class FormatError < Error

    attr_reader :path

    def initialize(message, source = nil)
      if source
        @path = source.path

        message = message + " in #{path}" if path
      end

      super message
    end

  end

  def self.build(manifest, skip_validation = false)
    package = FoobarMod::Package.new manifest.file_name
    package.manifest = manifest
    package.build skip_validation

    manifest.zip_file
  end

  ##
  # Creates a new FoobarMod::Package for the file at +mod+. +mod+ can also be
  # provided as an IO object.

  def initialize(mod)
    @mod = if mod.is_a?(FoobarMod::Package::Source)
             mod
           elsif mod.respond_to? :read
             FoobarMod::Package::IOSource.new mod
           else
             FoobarMod::Package::FileSource.new mod
           end

    @build_time      = ENV["SOURCE_DATE_EPOCH"] ? Time.at(ENV["SOURCE_DATE_EPOCH"].to_i).utc : Time.now
    @files           = nil
    @manifest        = nil
  end

  ##
  # Adds all files in the package's directory to the +zip+ file.

  def add_files(zip)
    ZipFileGenerator.new(@manifest.base_dir, zip).write
  end

  def build(skip_validation = false)
    @manifest.validate unless skip_validation

    @mod.with_write_io do |mod_io|
      Zip::OutputStream.write_buffer(mod_io) do |zip|
        add_files zip
      end
    end

    true
  end

  ##
  # A list of file names contained in this mod.

  def files
    return @files if @files and not @files.empty?

    @files = []

    each_zip_entry do |entry|
      @files << entry.name
    end

    @files
  end

  def manifest
    verify unless @manifest

    @manifest
  end

  ##
  # Loads the FoobarMod::Manifest from a zip entry.

  def load_manifest(entry) # :nodoc:
    @manifest = FoobarMod::Manifest.from_hcl entry.get_input_stream.read
  end

  ##
  # Validates the mod .zip contains required files (mod.hcl, init.lua).

  def verify
    @files    = []
    @manifest = nil

    verify_required_files

  rescue Errno::ENOENT => e
    raise FoobarMod::Package::FormatError.new e.message
  rescue Gem::Package::TarInvalidError => e
    raise FoobarMod::Package::FormatError.new e.message, @mod
  end

  def verify_required_files
    required = REQUIRED_FILES.map{ |f| [f, false] }.to_h

    each_zip_entry do |entry|
      if required.key? entry.name
        required[entry.name] = true

        if entry.name == "mod.hcl"
          load_manifest entry
        end
      end
    end

    REQUIRED_FILES.each do |f|
      if required[f] == false
        raise FoobarMod::Package::FormatError.new "Missing required file '#{f}'", @mod
      end
    end
  end

  def each_zip_entry
    @mod.with_read_io do |io|
      Zip::InputStream.open(io) do |zip|
        while entry = zip.get_next_entry
          yield entry
        end
      end
    end
  end

end

require 'foobar_mod/package/source'
require 'foobar_mod/package/file_source'
require 'foobar_mod/package/io_source'
