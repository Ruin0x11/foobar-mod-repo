# frozen_string_literal: true
require "test_helper"
require "foobar_mod"

require "minitest/benchmark"

class FoobarMod::TestVersion < ActiveSupport::TestCase

  class V < ::FoobarMod::Version
  end

  def test_bump
    assert_bumped_version_equal "5.3", "5.2.4"
  end

  def test_bump_trailing_zeros
    assert_bumped_version_equal "5.1", "5.0.0"
  end

  def test_bump_one_level
    assert_bumped_version_equal "6", "5"
  end

  # A FoobarMod::Version is already a FoobarMod::Version and therefore not transformed by
  # FoobarMod::Version.create

  def test_class_create
    real = FoobarMod::Version.new(1.0)

    assert_same  real, FoobarMod::Version.create(real)
    assert_nil   FoobarMod::Version.create(nil)
    assert_equal v("5.1"), FoobarMod::Version.create("5.1")

    ver = '1.1'.freeze
    assert_equal v('1.1'), FoobarMod::Version.create(ver)
  end

  def test_class_correct
    assert_equal true,  FoobarMod::Version.correct?("5")
    assert_equal true,  FoobarMod::Version.correct?("5.1")
    assert_equal true,  FoobarMod::Version.correct?("5.1.1")
    assert_equal true,  FoobarMod::Version.correct?("5.001.1")
    assert_equal false,  FoobarMod::Version.correct?("5.1.1.2")
    assert_equal false,  FoobarMod::Version.correct?("5.1.1-1")
    assert_equal false,  FoobarMod::Version.correct?("5.1.a")
    assert_equal false,  FoobarMod::Version.correct?("5.1.rc2")
    assert_equal false, FoobarMod::Version.correct?("an incorrect version")
    assert_equal false, FoobarMod::Version.correct?(nil)
  end

  def test_class_new_subclass
    v1 = FoobarMod::Version.new '1'
    v2 = V.new '1'

    refute_same v1, v2
  end

  def test_eql_eh
    assert_version_eql "1.2",    "1.2"
    refute_version_eql "1.2",    "1.2.0"
    refute_version_eql "1.2",    "1.3"
  end

  def test_equals2
    assert_version_equal "1.2",    "1.2"
    refute_version_equal "1.2",    "1.3"
  end

  # REVISIT: consider removing as too impl-bound
  def test_hash
    assert_equal v("1.2").hash, v("1.2").hash
    refute_equal v("1.2").hash, v("1.3").hash
    assert_equal v("1.2").hash, v("1.2.0").hash
  end

  def test_initialize
    ["1.0", "1.0 ", " 1.0 ", "1.0\n", "\n1.0\n", "1.0".freeze].each do |good|
      assert_version_equal "1.0", good
    end

    assert_version_equal "1", 1
  end

  def test_initialize_invalid
    invalid_versions = %W[
      junk
      1.0\n2.0
      1..2
      1.2\ 3.4
    ]

    # DON'T TOUCH THIS WITHOUT CHECKING CVE-2013-4287
    invalid_versions << "2.3422222.222.222222222.22222.ads0as.dasd0.ddd2222.2.qd3e."

    invalid_versions.each do |invalid|
      e = assert_raises ArgumentError, invalid do
        FoobarMod::Version.new invalid
      end

      assert_equal "Malformed version number string #{invalid}", e.message, invalid
    end
  end

  def bench_anchored_version_pattern
    assert_performance_linear 0.5 do |count|
      version_string = count.times.map {|i| "0" * i.succ }.join(".") << "."
      version_string =~ FoobarMod::Version::ANCHORED_VERSION_PATTERN
    end
  rescue RegexpError
    skip "It fails to allocate the memory for regex pattern of FoobarMod::Version::ANCHORED_VERSION_PATTERN"
  end

  def test_empty_version
    ["", "   ", " "].each do |empty|
      assert_equal false, FoobarMod::Version.correct?(empty)
    end
  end

  def test_spaceship
    assert_equal(0, v("1.0")       <=> v("1.0.0"))
    assert_equal(1, v("1.8.2")     <=> v("0.0.0"))

    assert_nil v("1.0") <=> "whatever"
  end

  def test_approximate_recommendation
    assert_approximate_equal "~> 1.0", "1"
    assert_approximate_satisfies_itself "1"

    assert_approximate_equal "~> 1.0", "1.0"
    assert_approximate_satisfies_itself "1.0"

    assert_approximate_equal "~> 1.2", "1.2"
    assert_approximate_satisfies_itself "1.2"

    assert_approximate_equal "~> 1.2", "1.2.0"
    assert_approximate_satisfies_itself "1.2.0"

    assert_approximate_equal "~> 1.2", "1.2.3"
    assert_approximate_satisfies_itself "1.2.3"
  end

  def test_to_s
    assert_equal "5.2.4", v("5.2.4").to_s
  end

  # modifying the segments of a version should not affect the segments of the cached version object
  def test_segments
    v('9.8.7').segments[2] += 1

    refute_version_equal "9.8.8", "9.8.7"
    assert_equal         [9,8,7], v("9.8.7").segments
  end

  def test_canonical_segments
    assert_equal [1], v("1.0.0").canonical_segments
    assert_equal [1, 0, 1], v("1.0.1").canonical_segments
  end

  # Assert that +expected+ is the "approximate" recommendation for +version+.

  def assert_approximate_equal(expected, version)
    assert_equal expected, v(version).approximate_recommendation
  end

  # Assert that the "approximate" recommendation for +version+ satifies +version+.

  def assert_approximate_satisfies_itself(version)
    gem_version = v(version)

    assert FoobarMod::Requirement.new(gem_version.approximate_recommendation).satisfied_by?(gem_version)
  end

  # Assert that bumping the +unbumped+ version yields the +expected+.

  def assert_bumped_version_equal(expected, unbumped)
    assert_version_equal expected, v(unbumped).bump
  end

  # Assert that two versions are equal. Handles strings or
  # FoobarMod::Version instances.

  def assert_version_equal(expected, actual)
    assert_equal v(expected), v(actual)
    assert_equal v(expected).hash, v(actual).hash, "since #{actual} == #{expected}, they must have the same hash"
  end

  # Assert that two versions are eql?. Checks both directions.

  def assert_version_eql(first, second)
    first, second = v(first), v(second)
    assert first.eql?(second), "#{first} is eql? #{second}"
    assert second.eql?(first), "#{second} is eql? #{first}"
  end

  def assert_less_than(left, right)
    l = v(left)
    r = v(right)
    assert l < r, "#{left} not less than #{right}"
  end

  # Refute the assumption that two versions are eql?. Checks both
  # directions.

  def refute_version_eql(first, second)
    first, second = v(first), v(second)
    refute first.eql?(second), "#{first} is NOT eql? #{second}"
    refute second.eql?(first), "#{second} is NOT eql? #{first}"
  end

  # Refute the assumption that the two versions are equal?.

  def refute_version_equal(unexpected, actual)
    refute_equal v(unexpected), v(actual)
  end

end
