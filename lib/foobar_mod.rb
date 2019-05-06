module FoobarMod
end

require "foobar_mod/dependency"
require "foobar_mod/manifest"
require "foobar_mod/package"
require "foobar_mod/requirement"
require "foobar_mod/version"

module FoobarMod

  READ_BINARY_ERRORS = [Errno::EACCES, Errno::EROFS, Errno::ENOSYS, Errno::ENOTSUP]

  WRITE_BINARY_ERRORS = [Errno::ENOSYS, Errno::ENOTSUP]

  ##
  # Safely read a file in binary mode on all platforms.

  def self.read_binary(path)
    File.open path, 'rb+' do |f|
      f.flock(File::LOCK_EX)
      f.read
    end
  rescue *READ_BINARY_ERRORS
    File.open path, 'rb' do |f|
      f.read
    end
  rescue Errno::ENOLCK # NFS
    if Thread.main != Thread.current
      raise
    else
      File.open path, 'rb' do |f|
        f.read
      end
    end
  end

  ##
  # Safely write a file in binary mode on all platforms.
  def self.write_binary(path, data)
    open(path, 'wb') do |io|
      begin
        io.flock(File::LOCK_EX)
      rescue *WRITE_BINARY_ERRORS
      end
      io.write data
    end
  rescue Errno::ENOLCK # NFS
    if Thread.main != Thread.current
      raise
    else
      open(path, 'wb') do |io|
        io.write data
      end
    end
  end
end
