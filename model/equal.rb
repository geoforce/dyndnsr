# Main dyndnser namespace
module DynDnsR
  Equal = Class.new(Sequel::Model)
  # The record which becomes the =host line in a tinydns data file
  # This maps both an A record and a PTR, so only one # of these is
  # allowed for any host.
  class Equal
    set_dataset :equals
    def self.create_record(user_id, host, ip, ttl = 86_400)
      record = find(host: host)
      if record
        return false if record.ip != ip
        if record.ttl != ttl.to_i
          record.ttl = ttl.to_i
          record.save
        end
        record.write!
      else
        create(host: host, ip: ip, ttl: ttl, user_id: user_id).write!
      end
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

    def write!(force = false)
      return self if File.exist?(file) && !force
      FileUtils.mkdir_p(dir) unless dir.directory?
      File.open(file, 'w') { |f| f.puts record }
      self.written = true
      save
    end
  end
end
