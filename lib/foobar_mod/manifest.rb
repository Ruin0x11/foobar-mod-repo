# frozen_string_literal: true

##
# Serves the same function as Gem::Specification.

class FoobarMod::Manifest
  ##
  # Identifier. Required to be unique.

  attr_accessor :identifier

  ##
  # Display name. Not required to be unique.

  attr_accessor :name

  ##
  # The mod's version. It must have the format '<major>.<minor>.<patch>'.

  attr_reader :version

  ##
  # A short summary of this mod's features.

  attr_reader :summary

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
  # License of this mod (SPDX ID).

  attr_accessor :license
end
