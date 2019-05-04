# frozen_string_literal: true

##
# Based on Gem::Dependency from RubyGems.

require "foobar_mod/requirement"

class FoobarMod::Dependency
  attr_accessor :identifier

  ##
  # Constructs a dependency with +identifier+ and +requirements+. The last
  # argument can optionally be the dependency type, which defaults to
  # <tt>:runtime</tt>.

  def initialize(identifier, *requirements)
    unless String === identifier
      raise ArgumentError,
            "dependency identifier must be a String, was #{identifier.inspect}"
    end

    requirements = requirements.first if 1 == requirements.length # unpack

    @identifier  = identifier
    @requirement = FoobarMod::Requirement.create requirements
  end

  ##
  # A dependency's hash is the XOR of the hashes of +identifier+ and
  # +requirement+.

  def hash # :nodoc:
    identifier.hash ^ requirement.hash
  end

  ##
  # Is this dependency simply asking for the latest version
  # of a mod?

  def latest_version?
    @requirement.none?
  end

  ##
  # What does this dependency require?

  def requirement
    return @requirement if defined?(@requirement) and @requirement
  end

  def requirements_list
    requirement.as_list
  end

  def to_s
    "#{identifier} (#{requirement})"
  end

  def ==(other) # :nodoc:
    FoobarMod::Dependency === other &&
      self.identifier        == other.identifier &&
      self.requirement == other.requirement
  end

  ##
  # Dependencies are ordered by identifier.

  def <=>(other)
    self.identifier <=> other.identifier
  end

  ##
  # Uses this dependency as a pattern to compare to +other+. This
  # dependency will match if the identifier matches the other's identifier, and
  # other has only an equal version requirement that satisfies this
  # dependency.

  def =~(other)
    unless FoobarMod::Dependency === other
      return false unless other.respond_to?(:identifier) && other.respond_to?(:version)
      other = FoobarMod::Dependency.new other.identifier, other.version
    end

    return false unless identifier === other.identifier

    reqs = other.requirement.requirements

    return false unless reqs.length == 1
    return false unless reqs.first.first == '=='

    version = reqs.first.last

    requirement.satisfied_by? version
  end

  alias === =~

  ##
  # Merges the requirements of +other+ into this dependency

  def merge(other)
    unless identifier == other.identifier
      raise ArgumentError,
            "#{self} and #{other} have different identifiers"
    end

    default = FoobarMod::Requirement.default
    self_req  = self.requirement
    other_req = other.requirement

    return self.class.new identifier, self_req  if other_req == default
    return self.class.new identifier, other_req if self_req  == default

    self.class.new identifier, self_req.as_list.concat(other_req.as_list)
  end

  ##
  # True if the dependency will not always match the latest version.

  def specific?
    @requirement.specific?
  end
end
