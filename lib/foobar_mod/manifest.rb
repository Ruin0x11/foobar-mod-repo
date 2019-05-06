# frozen_string_literal: true

##
# Serves the same function as Gem::Specification.

require "foobar_mod/manifest_validator"

class FoobarMod::Manifest

  class FoobarMod::InvalidManifestException < Exception; end

  ##
  # Identifier. Required to be unique.

  attr_accessor :identifier

  ##
  # Display name. Not required to be unique.

  attr_accessor :name

  ##
  # The mod's version. It must have the format '<major>.<minor>.<patch>'.

  attr_reader :version

  def version=(version)
    @version = FoobarMod::Version.create(version)
    invalidate_memoized_attributes
    @version
  end

  ##
  # A short summary of this mod's features.

  attr_reader :summary

  def summary=(str)
    @summary = str.to_s.strip.
      gsub(/(\w-)\n[ \t]*(\w)/, '\1\2').gsub(/\n[ \t]*/, " ") # so. weird.
  end

  ##
  # A list of authors for this mod.
  #
  # Alternatively, a single author can be specified by assigning a string to
  # `manifest.author`

  def authors=(value)
    @authors = Array(value).flatten.grep(String)
  end

  def author=(o)
    self.authors = [o]
  end

  ##
  # Singular reader for #authors.  Returns the first author in the list

  def author
    val = authors and val.first
  end

  ##
  # The list of author names who wrote this mod.

  def authors
    @authors ||= []
  end

  ##
  # Licenses of this mod (SPDX IDs).

  def licenses=(licenses)
    @licenses = Array licenses
  end

  def license=(o)
    self.licenses = [o]
  end

  ##
  # Singular accessor for #licenses

  def license
    licenses.first
  end

  ##
  # Plural accessor for setting licenses
  #
  # See #license= for details

  def licenses
    @licenses ||= []
  end

  ##
  # The file this mod was loaded from. This attribute is not
  # persisted. It can be a mod.hcl file or a .zip archive containing
  # it at the root.

  attr_reader :loaded_from

  def loaded_from=(loaded_from)
    if String === loaded_from
      @loaded_from = File.expand_path(loaded_from)
    else
      @loaded_from = loaded_from
    end
    invalidate_memoized_attributes
    @loaded_from
  end

  def initialize(identifier = nil, version = nil, loaded_from = nil)
    @zip_file = nil
    @loaded_from = nil

    self.identifier = identifier if identifier
    self.version = version if version
    self.loaded_from = loaded_from if loaded_from

    yield self if block_given?
  end

  def self.load(io, loaded_from = nil)
    return unless io

    if String === io
      loaded_from = io.to_s
      io = File.open(io)
    end

    # TODO
    manifest = FoobarMod::Manifest.new do |m|
      m.identifier = "test"
      m.name = "test"
      m.version = "0.1.0"
      m.summary = "A summary."
      m.license = "MIT"
    end

    manifest.loaded_from = loaded_from

    io.close

    manifest
  end

  def full_identifier
    "#{identifier}-#{version.full_version}"
  end

  attr_writer :base_dir

  def base_dir
    if from_zip?
      File.join(File.dirname(loaded_from), File.basename(loaded_from, ".*"))
    elsif from_manifest_file?
      File.dirname(loaded_from)
    else
      nil
    end
  end

  ##
  # The default (generated) file name of the mod archive.
  #
  #   spec.file_name # => "example-1.0.gem"

  def file_name
    "#{full_identifier}.zip"
  end

  def manifest_name
    "mod.hcl"
  end

  def from_manifest_file?
    (loaded_from && File.basename(loaded_from) == "mod.hcl") || false
  end

  def from_zip?
    (loaded_from && File.extname(loaded_from) == ".zip") || false
  end

  def from_file?
    from_manifest_file? || from_zip?
  end

  ##
  # Returns the full path to the output zip file for this mod.

  def zip_file
    @zip_file ||= base_dir && File.expand_path(File.join(base_dir, "..", file_name))
  end

  ##
  # Returns the full path to this manifest's mod.hcl file.

  def manifest_file
    @manifest_file ||= base_dir && File.join(base_dir, manifest_name)
  end

  def self.from_hcl(hcl)
    # TODO
    FoobarMod::Manifest.load(StringIO.new)
  end

  def to_hcl
    "mod {}"
  end

  ##
  # Expire memoized instance variables that can incorrectly generate, replace
  # or miss files due changes in certain attributes used to compute them.

  def invalidate_memoized_attributes
    @zip_file = nil
    @manifest_file = nil
  end

  def validate
    FoobarMod::ManifestValidator.new(self).validate
  end
end
