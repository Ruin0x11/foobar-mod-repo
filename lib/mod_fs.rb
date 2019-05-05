module ModFs
  def self.instance
    @fs ||= ModFs::Local.new
  end

  def self.mock!
    @fs = ModFs::Local.new(Dir.mktmpdir)
  end

  class Local
    def initialize(base_dir = nil)
      @base_dir = base_dir
    end

    def store(key, body, _metadata = {})
      p "Store #{base_dir}/#{key}"
      FileUtils.mkdir_p File.dirname("#{base_dir}/#{key}")
      File.open("#{base_dir}/#{key}", 'wb') do |f|
        f.write(body)
      end
    end

    def get(key)
      File.read("#{base_dir}/#{key}")
    rescue Errno::ENOENT
      nil
    end

    def remove(key)
      FileUtils.rm("#{base_dir}/#{key}")
    rescue Errno::ENOENT
      false
    end

    def base_dir
      @base_dir || Rails.root.join('server')
    end
  end
end
