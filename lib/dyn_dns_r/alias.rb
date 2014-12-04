module DynDnsR
  # A record
  class Alias
    attr_reader :aka, :ip, :ttl, :alias
    def self.create(aka, ip, ttl = 86_400)
      new(aka, ip, ttl).write!
    end

    def initialize(host, ip, ttl = 86_400)
      @aka, @ip, @ttl = host, ip, ttl
    end

    def file
      @file ||= TOPLEVEL.join(ip, 'alias', aka)
    end

    def dir
      @dir ||= file.dirname
    end

    def record
      format('+%s:%s:%s', @aka, @ip, @ttl)
    end

    def write!
      FileUtils.mkdir_p dir unless dir.directory?
      File.open(file, 'a+') { |f| f.puts record }
      true
    end
  end
end
