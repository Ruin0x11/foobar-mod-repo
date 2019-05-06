# frozen_string_literal: true

##
# Based on Gem::Version from RubyGems, except no characters are
# allowed and only major, minor and patch are allowed at most.

class FoobarMod::Version
  autoload :Requirement, "foobar_mod/requirement"
  include Comparable

  VERSION_PATTERN = '[0-9]+(?>\.[0-9]+){0,2}'.freeze # :nodoc:
  ANCHORED_VERSION_PATTERN = /\A\s*(#{VERSION_PATTERN})\s*\z/.freeze # :nodoc:

  ##
  # A string representation of this Version.

  def version
    @version.dup
  end

  ##
  # The full version, with extra zeros prepended for minor and patch
  # if they are missing.

  def full_version
    segments = self.segments
    segments.push 0 while segments.size < 3
    segments.join(".")
  end

  alias to_s version

  ##
  # True if the +version+ string matches ElonaFoobar's requirements.

  def self.correct?(version)
    return false if version.nil?

    !!(version.to_s =~ ANCHORED_VERSION_PATTERN)
  end

  ##
  # Factory method to create a Version object. Input may be a Version
  # or a String. Intended to simplify client code.
  #
  #   ver1 = Version.create('1.3.17')   # -> (Version object)
  #   ver2 = Version.create(ver1)       # -> (ver1)
  #   ver3 = Version.create(nil)        # -> nil

  def self.create(input)
    if self === input  # check yourself before you wreck yourself
      input
    elsif input.nil?
      nil
    else
      new input
    end
  end

  @@all = {}

  def self.new(version) # :nodoc:
    return super unless FoobarMod::Version == self

    @@all[version] ||= super
  end

  ##
  # Constructs a Version from the +version+ string.  A version string is a
  # series of digits or ASCII letters separated by dots.

  def initialize(version)
    unless self.class.correct?(version)
      raise ArgumentError, "Malformed version number string #{version}"
    end

    @version = version.to_s.strip
    @segments = nil
  end

  ##
  # Return a new version object where the next to the last revision
  # number is one greater (e.g., 5.3.1 => 5.4).

  def bump
    @bump ||= begin
                segments = self.segments
                segments.pop if segments.size > 1

                segments[-1] = segments[-1].succ
                self.class.new segments.join(".")
              end
  end

  ##
  # A Version is only eql? to another version if it's specified to the
  # same precision. Version "1.0" is not the same as version "1".

  def eql?(other)
    self.class === other and @version == other._version
  end

  def hash # :nodoc:
    canonical_segments.hash
  end

  def segments # :nodoc:
    _segments.dup
  end

  ##
  # A recommended version for use with a ~> Requirement.

  def approximate_recommendation
    segments = self.segments

    segments.pop    while segments.size > 2
    segments.push 0 while segments.size < 2

    recommendation = "~> #{segments.join(".")}"
    recommendation
  end

  ##
  # Compares this version with +other+ returning -1, 0, or 1 if the
  # other version is larger, the same, or smaller than this
  # one. Attempts to compare to something that's not a
  # <tt>Gem::Version</tt> return +nil+.

  def <=>(other)
    return unless FoobarMod::Version === other
    return 0 if @version == other._version || canonical_segments == other.canonical_segments

    lhsegments = canonical_segments
    rhsegments = other.canonical_segments

    lhsize = lhsegments.size
    rhsize = rhsegments.size
    limit  = (lhsize > rhsize ? lhsize : rhsize) - 1

    i = 0

    while i <= limit
      lhs, rhs = lhsegments[i] || 0, rhsegments[i] || 0
      i += 1

      next      if lhs == rhs
      return -1 if String  === lhs && Numeric === rhs
      return  1 if Numeric === lhs && String  === rhs

      return lhs <=> rhs
    end

    return 0
  end

  def canonical_segments
    @canonical_segments ||=
      _split_segments.map! do |segments|
        segments.reverse_each.drop_while {|s| s == 0 }.reverse
      end.reduce(&:concat)
  end

  protected

  def _version
    @version
  end

  def _segments
    # segments is lazy so it can pick up version values that come from
    # old marshaled versions, which don't go through marshal_load.
    # since this version object is cached in @@all, its @segments should be frozen

    @segments ||= @version.scan(/[0-9]+|[a-z]+/i).map do |s|
      /^\d+$/ =~ s ? s.to_i : s
    end.freeze
  end

  def _split_segments
    string_start = _segments.index {|s| s.is_a?(String) }
    string_segments  = segments
    numeric_segments = string_segments.slice!(0, string_start || string_segments.size)
    return numeric_segments, string_segments
  end
end
