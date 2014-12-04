module DynDnsR
  # A record
  class A
    attr_reader :host, :ip, :ttl
    def self.create(host, ip, ttl = 86400)
      new(host, ip, ttl).write!
    end

    def initialize(host, ip, ttl = 86400)
      @host, @ip, @ttl = host, ip, ttl
    end

    def file
      @file ||= TOPLEVEL.join(ip, 'hostname')
    end

    def dir
      @dir ||= file.dirname
    end

    def record
      format('=%s:%s:%s', @host, @ip, @ttl)
    end

    def write!
      return false if File.exist? file
      FileUtils.mkdir_p(dir) unless dir.directory?
      File.open(file, "w") { |f| f.puts record }
      true
    end
  end
end
