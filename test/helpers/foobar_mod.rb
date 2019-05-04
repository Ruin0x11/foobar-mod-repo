require "foobar_mod"

module FoobarMod::TestHelpers
  ##
  # Constructs a new FoobarMod::Version.

  def v(string)
    FoobarMod::Version.create string
  end

  ##
  # Constructs a new FoobarMod::Requirement.

  def req(*requirements)
    return requirements.first if FoobarMod::Requirement === requirements.first
    FoobarMod::Requirement.create requirements
  end

  ##
  # Construct a new FoobarMod::Dependency.

  def dep(name, *requirements)
    FoobarMod::Dependency.new name, *requirements
  end

end
