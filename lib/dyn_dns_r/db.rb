require 'sequel'
require 'sequel/adapters/postgres'
require_relative '../../options'

module DynDnsR
  @db ||= nil

  # Execute a block within a connection where mergejoin and hashjoin are off,
  # To fool the query planner on tables where the indexes are very large where pg
  # overestimates the cost of an index and uses a seq scan where it should not
  def self.without_hashjoin(&block)
    db.execute('set enable_mergejoin = off; set enable_hashjoin = off')
    res = block.call
    db.execute('set enable_mergejoin = on; set enable_hashjoin = on')
    res
  end

  def self.db
    return @db if @db
    self.db = options.db
    @db
  end

  def self.db=(other)
    if other.is_a? Sequel::Postgres::Database
      printable_other = other.inspect.sub(/"password"=>"(.*)",/, '"password"=>"*PASSWORD*",')
      if @db.respond_to?(:disconnect)
        printable_me = @db.inspect.sub(/"password"=>"(.*)",/, '"password"=>"*PASSWORD*",')
        printable_me = printable_me.sub(/([^:]*)@/, '*password*@')
        log.unknown "Disconnecting from #{printable_me}"
        @db.disconnect
      end
      log.unknown "Using pre-existing #{other} (#{printable_other})"
      @db = other
    else
      printable_other = other.sub(/postgres:\/\/([^:]*):.*@/, 'postgres://\1:*password*@')
      log.unknown "Connecting #{name}.db to #{printable_other}"
      if DynDnsR.options.db_servers
        server_hash = Hash[DynDnsR.options.db_servers.map { |k, v| [k, v.symbolize_keys] }]
      else
        server_hash = {}
      end
      @db = Sequel.connect(other, servers: {}.merge(server_hash))
    end
  end

  def self.db_log=(other)
    db.loggers = other.nil? ? [] : [Logger.new(log_location(other), options.max_log_files, options.max_log_size)]
  end

end

DynDnsR.db_log = DynDnsR.options.db_log
