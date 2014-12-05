# Main dyndnser namespace
module DynDnsR
  A = Class.new(Sequel::Model)
  # A record
  class A
    set_dataset :a_records
    def self.create_record(user_id, host, ip, ttl = 86_400)
      record = find host: host, ip: ip
      if record
        if record.ttl != ttl.to_i
          record.ttl = ttl.to_i
          record.save
        end
        return record.write!
      end
      new(host: host, ip: ip, ttl: ttl, user_id: user_id).write!
    end

    def file
      @file ||= TOPLEVEL.join(ip, 'alias', host)
    end

    def dir
      @dir ||= file.dirname
    end

    def record
      format('+%s:%s:%s', host, ip, ttl)
    end

    def write!(force = false)
      return self if written && !force
      FileUtils.mkdir_p dir unless dir.directory?
      File.open(file, 'a+') { |f| f.puts record }
      self.written = true
      self.save
    end
  end
end
