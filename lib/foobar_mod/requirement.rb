# frozen_string_literal: true

##
# Based on Gem::Requirement from RubyGems.

require "foobar_mod/version"

class FoobarMod::Requirement
  OPS = { #:nodoc:
    "==" =>  lambda { |v, r| v == r },
    "!=" =>  lambda { |v, r| v != r },
    ">"  =>  lambda { |v, r| v >  r },
    "<"  =>  lambda { |v, r| v <  r },
    ">=" =>  lambda { |v, r| v >= r },
    "<=" =>  lambda { |v, r| v <= r },
    "~>" =>  lambda { |v, r| v >= r && v < r.bump },
  }.freeze

  quoted = OPS.keys.map { |k| Regexp.quote k }.join "|"
  PATTERN_RAW = "\\s*(#{quoted})?\\s*(#{FoobarMod::Version::VERSION_PATTERN})\\s*".freeze # :nodoc:

  ##
  # A regular expression that matches a requirement

  PATTERN = /\A#{PATTERN_RAW}\z/.freeze

  ##
  # The default requirement matches any version

  DefaultRequirement = [">=", FoobarMod::Version.new(0)].freeze

  ##
  # Raised when a bad requirement is encountered

  class BadRequirementError < ArgumentError; end

  ##
  # Factory method to create a FoobarMod::Requirement object.  Input may be
  # a Version, a String, or nil.  Intended to simplify client code.
  #
  # If the input is "weird", the default version requirement is
  # returned.

  def self.create(*inputs)
    return new inputs if inputs.length > 1

    input = inputs.shift

    case input
    when FoobarMod::Requirement then
      input
    when FoobarMod::Version, Array then
      new input
    else
      if input.respond_to? :to_str
        new [input.to_str]
      else
        default
      end
    end
  end

  ##
  # A default "version requirement" can surely _only_ be '>= 0'.

  def self.default
    new '>= 0'
  end

  ##
  # Parse +obj+, returning an <tt>[op, version]</tt> pair. +obj+ can
  # be a String or a FoobarMod::Version.
  #
  # If +obj+ is a String, it can be either a full requirement
  # specification, like <tt>">= 1.2"</tt>, or a simple version number,
  # like <tt>"1.2"</tt>.
  #
  #     parse("> 1.0")                 # => [">", FoobarMod::Version.new("1.0")]
  #     parse(FoobarMod::Version.new("1.0")) # => ["==,  FoobarMod::Version.new("1.0")]

  def self.parse(obj)
    return ["==", obj] if FoobarMod::Version === obj
    return DefaultRequirement if obj == "*"

    unless PATTERN =~ obj.to_s
      raise BadRequirementError, "Illformed requirement [#{obj.inspect}]"
    end

    if $1 == ">=" && $2 == "0"
      DefaultRequirement
    else
      [$1 || "==", FoobarMod::Version.new($2)]
    end
  end

  ##
  # An array of requirement pairs. The first element of the pair is
  # the op, and the second is the FoobarMod::Version.

  attr_reader :requirements #:nodoc:

  ##
  # Constructs a requirement from +requirements+. Requirements can be
  # Strings, FoobarMod::Versions, or Arrays of those. +nil+ and duplicate
  # requirements are ignored. An empty set of +requirements+ is the
  # same as <tt>">= 0"</tt>.

  def initialize(*requirements)
    requirements = requirements.flatten
    requirements.compact!
    requirements.uniq!

    if requirements.empty?
      @requirements = [DefaultRequirement]
    else
      @requirements = requirements.map! { |r| self.class.parse r }
    end
  end

  ##
  # Concatenates the +new+ requirements onto this requirement.

  def concat(new)
    new = new.flatten
    new.compact!
    new.uniq!
    new = new.map { |r| self.class.parse r }

    @requirements.concat new
  end

  ##
  # true if this mod has no requirements.

  def none?
    if @requirements.size == 1
      @requirements[0] == DefaultRequirement
    else
      false
    end
  end

  ##
  # true if the requirement is for only an exact version

  def exact?
    return false unless @requirements.size == 1
    @requirements[0][0] == "=" && @requirements[0][1] == "="
  end

  def as_list # :nodoc:
    requirements.map { |op, version| "#{op} #{version}" }
  end

  def hash # :nodoc:
    requirements.sort.hash
  end

  def pretty_print(q) # :nodoc:
    q.group 1, 'FoobarMod::Requirement.new(', ')' do
      q.pp as_list
    end
  end

  ##
  # True if +version+ satisfies this Requirement.

  def satisfied_by?(version)
    raise ArgumentError, "Need a FoobarMod::Version: #{version.inspect}" unless
      FoobarMod::Version === version
    # #28965: syck has a bug with unquoted '=' YAML.loading as YAML::DefaultKey
    requirements.all? { |op, rv| (OPS[op] || OPS["=="]).call version, rv }
  end

  alias :=== :satisfied_by?
  alias :=~ :satisfied_by?

  ##
  # True if the requirement will not always match the latest version.

  def specific?
    return true if @requirements.length > 1 # GIGO, > 1, > 2 is silly

    not %w[> >=].include? @requirements.first.first # grab the operator
  end

  def to_s # :nodoc:
    as_list.join ", "
  end

  def ==(other) # :nodoc:
    return unless FoobarMod::Requirement === other

    # An == check is always necessary
    return false unless requirements == other.requirements

    # An == check is sufficient unless any requirements use ~>
    return true unless _tilde_requirements.any?

    # If any requirements use ~> we use the stricter `#eql?` that also checks
    # that version precision is the same
    _tilde_requirements.eql?(other._tilde_requirements)
  end

  protected

  def _tilde_requirements
    requirements.select { |r| r.first == "~>" }
  end
end
