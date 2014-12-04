module DynDnsR
  def self.log=(other)
    @log = if other.is_a?(Logger)
             other
           else
             Logger.new(log_location(other), 10, 10_240_000)
           end
    @log.level = DynDnsR.options.log_level
    @log
  end

  def self.log
    return @log if @log
    self.log = DynDnsR.options.logfile
    @log
  end

  def self.log_level=(other)
    log.level = other.to_i
  end
end
