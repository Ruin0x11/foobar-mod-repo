# frozen_string_literal: true
##
# This is a private class, do not depend on it directly. Instead, pass an IO
# object to `FoobarMod::Package.new`.

class FoobarMod::Package::IOSource < FoobarMod::Package::Source # :nodoc: all

  attr_reader :io

  def initialize(io)
    @io = io
  end

  def start
    @start ||= begin
      if io.pos > 0
        raise FoobarMod::Package::Error, "Cannot read start unless IO is at start"
      end

      value = io.read 20
      io.rewind
      value
    end
  end

  def present?
    true
  end

  def with_read_io
    yield io
  end

  def with_write_io
    yield io
  end

  def path
  end

end
