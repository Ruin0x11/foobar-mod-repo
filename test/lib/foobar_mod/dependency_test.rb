# frozen_string_literal: true
require "test_helper"
require "foobar_mod/dependency"

class FoobarMod::TestDependency < ActiveSupport::TestCase
  def test_initialize
    d = dep "pkg", "> 1.0"

    assert_equal "pkg", d.identifier
    assert_equal req("> 1.0"), d.requirement
  end

  def test_initialize_type_bad
    e = assert_raises ArgumentError do
      FoobarMod::Dependency.new 'monkey' => '1.0'
    end

    assert_equal 'dependency identifier must be a String, was {"monkey"=>"1.0"}',
                 e.message
  end

  def test_initialize_double
    d = dep "pkg", "> 1.0", "< 2.0"
    assert_equal req("> 1.0", "< 2.0"), d.requirement
  end

  def test_initialize_empty
    d = dep "pkg"
    assert_equal req(">= 0"), d.requirement
  end

  def test_initialize_version
    d = dep "pkg", v("2")
    assert_equal req("== 2"), d.requirement
  end

  def test_equals2
    o  = dep "other"
    d  = dep "pkg", "> 1.0"
    d1 = dep "pkg", "> 1.1"

    assert_equal d, d.dup
    assert_equal d.dup, d

    refute_equal d, d1
    refute_equal d1, d

    refute_equal d, o
    refute_equal o, d

    refute_equal d, Object.new
    refute_equal Object.new, d
  end

  def test_equals_tilde
    d = dep "a", "0"

    assert_match d,                  d,             "match self"
    assert_match dep("a", ">= 0"),   d,             "match version exact"
    assert_match dep("a", ">= 0"),   dep("a", "1"), "match version"
    refute_match dep("a"), Object.new
  end

  def test_equals_tilde_object
    o = Object.new
    def o.identifier ; 'a' end
    def o.version    ; '0' end

    assert_match dep("a"), o
  end

  def test_hash
    d = dep "pkg", "1.0"

    assert_equal d.hash, d.dup.hash
    assert_equal d.dup.hash, d.hash

    refute_equal dep("pkg", "1.0").hash,   dep("pkg", "2.0").hash, "requirement"
    refute_equal dep("pkg", "1.0").hash,   dep("abc", "1.0").hash, "identifier"
  end

  def test_merge
    a1 = dep 'a', '~> 1.0'
    a2 = dep 'a', '== 1.0'

    a3 = a1.merge a2

    assert_equal dep('a', '~> 1.0', '== 1.0'), a3
  end

  def test_merge_default
    a1 = dep 'a'
    a2 = dep 'a', '1'

    a3 = a1.merge a2

    assert_equal dep('a', '1'), a3
  end

  def test_merge_identifier_mismatch
    a = dep 'a'
    b = dep 'b'

    e = assert_raises ArgumentError do
      a.merge b
    end

    assert_equal 'a (>= 0) and b (>= 0) have different identifiers',
                 e.message
  end

  def test_merge_other_default
    a1 = dep 'a', '1'
    a2 = dep 'a'

    a3 = a1.merge a2

    assert_equal dep('a', '1'), a3
  end

  def test_specific
    refute dep('a', '> 1').specific?

    assert dep('a', '== 1').specific?
  end
end
